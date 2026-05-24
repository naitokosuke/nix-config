import type { DirNode, FileEntry, Route, TreeNode, WalkthroughSection } from "./types.ts";
import { ancestorsOf, files, filesByPath, tree } from "./data.ts";
import { highlight, escapeHtml } from "./syntax.ts";
import { iconForFile, icons } from "./icons.ts";
import { Router, routeToHref } from "./router.ts";
import { mountWelcomeCanvas } from "./canvas-bg.ts";

/**
 * Tiny inline-Markdown renderer for prose copy. Handles paragraph splits on
 * blank lines, and inline `code`, **bold**, and [text](url). Everything else
 * is HTML-escaped.
 */
function renderProse(text: string): string {
  const escaped = escapeHtml(text.trim());
  return escaped
    .split(/\n\s*\n/)
    .map((paragraph) => {
      const inline = paragraph
        .replace(/\s+/g, " ")
        .replace(/`([^`]+)`/g, "<code>$1</code>")
        .replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>")
        .replace(
          /\[([^\]]+)\]\(([^)]+)\)/g,
          '<a href="$2" target="_blank" rel="noopener noreferrer">$1</a>',
        );
      return `<p>${inline}</p>`;
    })
    .join("");
}

function renderCodeExcerpt(file: FileEntry, range: readonly [number, number]): string {
  const allLines = file.content.split("\n");
  const start = Math.max(1, range[0]);
  const end = Math.min(allLines.length, range[1]);
  if (end < start) return "";
  const chunk = allLines.slice(start - 1, end).join("\n");
  const lineNumbers = Array.from(
    { length: end - start + 1 },
    (_, i) => `<span class="ln">${start + i}</span>`,
  ).join("");
  const code = highlight(chunk, file.lang);
  const meta = start === end ? `line ${start}` : `lines ${start}–${end}`;
  return `
    <figure class="excerpt">
      <figcaption>${escapeHtml(meta)}</figcaption>
      <pre class="code excerpt-code"><span class="line-numbers">${lineNumbers}</span><code class="lang-${file.lang}">${code}</code></pre>
    </figure>
  `;
}

function renderWalkthroughSection(section: WalkthroughSection, file: FileEntry): string {
  const heading = section.title
    ? `<h2 class="section-title">${escapeHtml(section.title)}</h2>`
    : "";
  const prose = `<div class="section-prose">${renderProse(section.prose)}</div>`;
  const excerpt = section.lines ? renderCodeExcerpt(file, section.lines) : "";
  return `<section class="walkthrough-section">${heading}${prose}${excerpt}</section>`;
}

const SUPPORTS_VIEW_TRANSITIONS =
  typeof document !== "undefined" && typeof document.startViewTransition === "function";

function withTransition(update: () => void): void {
  if (SUPPORTS_VIEW_TRANSITIONS) {
    document.startViewTransition?.(update);
  } else {
    update();
  }
}

function renderTree(
  node: DirNode,
  openDirs: ReadonlySet<string>,
  activePath: string | null,
): string {
  const childrenHtml = node.children
    .map((child) => renderNode(child, openDirs, activePath, 1))
    .join("");
  return childrenHtml;
}

function renderNode(
  node: TreeNode,
  openDirs: ReadonlySet<string>,
  activePath: string | null,
  depth: number,
): string {
  const indent = depth * 12;
  if (node.type === "dir") {
    const open = openDirs.has(node.path);
    const folderIcon = open ? icons.folderOpen() : icons.folder();
    const childrenHtml = open
      ? node.children.map((child) => renderNode(child, openDirs, activePath, depth + 1)).join("")
      : "";
    return `
      <div class="tree-item tree-dir" data-dir="${node.path}" style="--depth:${indent}px;">
        <button class="tree-row" type="button" data-action="toggle-dir" data-path="${node.path}" aria-expanded="${open}">
          <span class="tree-chevron${open ? " open" : ""}">${icons.chevronRight({ size: 12 })}</span>
          <span class="tree-icon">${folderIcon}</span>
          <span class="tree-label">${escapeHtml(node.name)}</span>
        </button>
        <div class="tree-children" data-children="${node.path}" ${open ? "" : 'hidden="until-found"'}>
          ${childrenHtml}
        </div>
      </div>
    `;
  }

  const isActive = activePath === node.path;
  return `
    <div class="tree-item tree-file${isActive ? " active" : ""}" style="--depth:${indent}px;">
      <a class="tree-row" href="${routeToHref({ kind: "file", path: node.path })}" data-action="open-file" data-path="${node.path}">
        <span class="tree-chevron"></span>
        <span class="tree-icon">${iconForFile(node.name)}</span>
        <span class="tree-label">${escapeHtml(node.name)}</span>
      </a>
    </div>
  `;
}

function renderBreadcrumb(filePath: string): string {
  const parts = filePath.split("/");
  return parts
    .map((part, idx) => {
      const isLast = idx === parts.length - 1;
      const trail = parts.slice(0, idx + 1).join("/");
      const icon = isLast ? iconForFile(part) : icons.chevronRight({ size: 12 });
      const separator =
        idx === 0 ? "" : `<span class="bc-sep">${icons.chevronRight({ size: 12 })}</span>`;
      return `${separator}<span class="bc-part${isLast ? " last" : ""}" data-trail="${trail}">${isLast ? `<span class="bc-icon">${icon}</span>` : ""}${escapeHtml(part)}</span>`;
    })
    .join("");
}

function renderFullSource(file: FileEntry): string {
  const lines = file.content.split("\n");
  const lineNumbers = lines.map((_, idx) => `<span class="ln">${idx + 1}</span>`).join("");
  const code = highlight(file.content, file.lang);
  return `<pre class="code"><span class="line-numbers">${lineNumbers}</span><code class="lang-${file.lang}">${code}</code></pre>`;
}

function renderEditor(file: FileEntry): string {
  const lines = file.content.split("\n");
  const langLabel = file.lang.toUpperCase();
  const tagsHtml = file.tags?.length
    ? `<ul class="tags">${file.tags
        .map((tag) => `<li>${icons.hash({ size: 10 })}<span>${escapeHtml(tag)}</span></li>`)
        .join("")}</ul>`
    : "";

  const walkthrough = file.walkthrough;
  const introHtml = walkthrough
    ? `<div class="walkthrough-intro">${renderProse(walkthrough.intro)}</div>`
    : file.about
      ? `<div class="walkthrough-intro">${renderProse(file.about)}</div>`
      : "";

  const sectionsHtml = walkthrough?.sections?.length
    ? walkthrough.sections.map((section) => renderWalkthroughSection(section, file)).join("")
    : "";

  const fullSource = renderFullSource(file);
  const fullSourceBlock = walkthrough?.sections?.length
    ? `<details class="full-source">
        <summary>
          <span class="full-source-summary">View the complete file</span>
          <span class="full-source-meta">${lines.length} lines · ${escapeHtml(file.name)}</span>
        </summary>
        <div class="code-scroller">${fullSource}</div>
      </details>`
    : `<div class="code-scroller">${fullSource}</div>`;

  return `
    <div class="editor-shell" style="view-transition-name: editor;">
      <header class="tabs">
        <div class="tab active" data-tab="${file.path}">
          <span class="tab-icon">${iconForFile(file.name)}</span>
          <span class="tab-name">${escapeHtml(file.name)}</span>
        </div>
        <div class="tabs-spacer"></div>
      </header>
      <div class="breadcrumb">${renderBreadcrumb(file.path)}</div>
      <div class="walkthrough-scroller">
        <article class="walkthrough">
          ${tagsHtml}
          ${introHtml}
          ${sectionsHtml}
          ${fullSourceBlock}
        </article>
      </div>
      <footer class="editor-foot">
        <span>${lines.length} lines</span>
        <span>·</span>
        <span>${file.content.length.toLocaleString()} chars</span>
        <span>·</span>
        <span>${langLabel}</span>
      </footer>
    </div>
  `;
}

function nixLogoSvg(): string {
  // Official Nix snowflake mark — path data verbatim from
  // https://github.com/NixOS/nixos-artwork/blob/master/logo/nix-snowflake-colours.svg
  // (CC BY 4.0). One "lambda-blade" path is rotated 6× around the figure
  // centre (407.11, -715.79) to assemble the 6-fold rotational pattern.
  return `
    <svg
      class="nix-bg"
      viewBox="0 0 501.56251 501.56249"
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      focusable="false"
    >
      <g transform="translate(-156.41121, 933.30685)">
        <g class="nix-rotor" transform="matrix(0.99994059,0,0,0.99994059,-0.06321798,33.188377)">
          <path
            id="nix-blade"
            d="m 309.54892,-710.38827 122.19683,211.67512 -56.15706,0.5268 -32.6236,-56.8692 -32.85645,56.5653 -27.90237,-0.011 -14.29086,-24.6896 46.81047,-80.4901 -33.22946,-57.8257 z"
          />
          <use href="#nix-blade" transform="rotate(60, 407.11155, -715.78724)" />
          <use href="#nix-blade" transform="rotate(120, 407.33916, -716.08356)" />
          <use href="#nix-blade" transform="rotate(180, 407.41868, -715.7565)" />
          <use href="#nix-blade" transform="rotate(-120, 407.28823, -715.86995)" />
          <use href="#nix-blade" transform="rotate(-60, 407.31177, -715.70016)" />
        </g>
      </g>
    </svg>
  `;
}

function renderWelcome(): string {
  const entries: ReadonlyArray<{
    readonly label: string;
    readonly path: string;
    readonly blurb: string;
  }> = [
    {
      label: "flake.nix",
      path: "flake.nix",
      blurb: "Entry point — composes inputs and per-host darwinConfigurations.",
    },
    {
      label: "hosts/",
      path: "hosts/common/default.nix",
      blurb: "System declaration layer via nix-darwin.",
    },
    {
      label: "home/",
      path: "home/naitokosuke/home.nix",
      blurb: "User declaration layer via home-manager.",
    },
  ];

  const cards = entries
    .map(
      (entry) => `
        <a class="entry-card" href="${routeToHref({ kind: "file", path: entry.path })}" data-action="open-file" data-path="${entry.path}">
          <span class="entry-label">${escapeHtml(entry.label)}</span>
          <span class="entry-blurb">${escapeHtml(entry.blurb)}</span>
        </a>
      `,
    )
    .join("");

  return `
    <div class="editor-shell welcome" style="view-transition-name: editor;">
      <header class="tabs">
        <div class="tab active" data-tab="home">
          <span class="tab-icon">${icons.sparkle({ size: 14 })}</span>
          <span class="tab-name">Welcome</span>
        </div>
        <div class="tabs-spacer"></div>
      </header>
      <div class="welcome-stage">
        <div class="welcome-bg" aria-hidden="true">
          <canvas data-welcome-canvas></canvas>
          ${nixLogoSvg()}
        </div>
        <div class="welcome-inner">
          <h1><span class="user">naitokosuke</span><span class="slash">/</span>dotfiles</h1>
          <p class="lede">
            An Apple Silicon macOS, declared end-to-end in <strong>Nix</strong>.
            <strong>nix-darwin</strong> owns the system layer and <strong>home-manager</strong> owns the user layer —
            the whole environment rebuilds from <code>flake.nix</code> with
            <code>darwin-rebuild switch --flake .#&lt;host&gt;</code>.
          </p>
          <nav class="entry-row" aria-label="entry points">${cards}</nav>
          <p class="attribution">
            Nix logo by Simon Frankau (revised by Tim Cuthbertson) ·
            <a href="https://creativecommons.org/licenses/by/4.0/" target="_blank" rel="noopener noreferrer">CC BY 4.0</a>
          </p>
        </div>
      </div>
    </div>
  `;
}

function renderStatusBar(route: Route): string {
  const fileBit =
    route.kind === "file"
      ? (() => {
          const file = filesByPath.get(route.path);
          if (!file) return "";
          return `
            <span class="status-cell">${icons.hash({ size: 12 })}<span>${file.lang}</span></span>
            <span class="status-cell">${file.content.split("\n").length} lines</span>
          `;
        })()
      : `<span class="status-cell">${files.length} files indexed</span>`;
  return `
    <div class="status-left">
      <span class="status-cell">${icons.branch({ size: 12 })}<span>main</span></span>
      <span class="status-cell">naitokosuke / dotfiles</span>
    </div>
    <div class="status-right">
      ${fileBit}
      <span class="status-cell">UTF-8</span>
      <span class="status-cell">LF</span>
    </div>
  `;
}

function renderShell(): string {
  return `
    <div class="workspace" data-workspace>
      <header class="title-bar">
        <div class="title-bar-left">
          <span class="dot dot-r" aria-hidden="true"></span>
          <span class="dot dot-y" aria-hidden="true"></span>
          <span class="dot dot-g" aria-hidden="true"></span>
        </div>
        <div class="title-bar-center">naitokosuke · dotfiles</div>
        <div class="title-bar-right">
          <a class="icon-btn" href="https://github.com/naitokosuke/dotfiles" target="_blank" rel="noopener" aria-label="GitHub">
            ${icons.github()}
          </a>
        </div>
      </header>
      <nav class="activity-bar" aria-label="primary">
        <button class="activity active" type="button" aria-label="Explorer">${icons.explorer()}</button>
        <button class="activity" type="button" aria-label="Search" data-action="focus-search">${icons.search()}</button>
        <button class="activity" type="button" aria-label="About" data-action="go-home">${icons.info()}</button>
      </nav>
      <aside id="sidebar" class="sidebar" aria-label="explorer">
        <span class="sheet-handle" aria-hidden="true"></span>
        <header class="sidebar-head">
          <span>Explorer</span>
          <button class="sidebar-close" type="button" data-action="close-menu" aria-label="Close menu">
            ${icons.close({ size: 14 })}
          </button>
        </header>
        <div class="sidebar-section">
          <button class="sidebar-section-head" type="button" aria-expanded="true">
            <span class="tree-chevron open">${icons.chevronRight({ size: 12 })}</span>
            <span>dotfiles</span>
          </button>
          <div class="tree" data-tree></div>
        </div>
      </aside>
      <button class="sidebar-backdrop" type="button" data-action="close-menu" aria-label="Close menu" tabindex="-1"></button>
      <main class="editor" data-editor></main>
      <footer class="status-bar" data-status></footer>
      <nav class="bottom-nav" aria-label="mobile primary" data-bottom-nav>
        <button class="bn-btn" type="button" data-action="toggle-menu" aria-controls="sidebar" aria-expanded="false" data-bn="files">
          ${icons.explorer({ size: 20 })}
          <span>Files</span>
        </button>
        <button class="bn-btn" type="button" data-action="go-home" data-bn="home">
          ${icons.sparkle({ size: 20 })}
          <span>Home</span>
        </button>
        <a class="bn-btn" href="https://github.com/naitokosuke/dotfiles" target="_blank" rel="noopener" data-bn="github">
          ${icons.github({ size: 20 })}
          <span>GitHub</span>
        </a>
      </nav>
    </div>
  `;
}

export class App {
  private readonly root: HTMLElement;
  private readonly router = new Router();
  private readonly openDirs = new Set<string>();
  private disposeCanvas: (() => void) | null = null;

  constructor(root: HTMLElement) {
    this.root = root;
  }

  start(): void {
    this.root.innerHTML = renderShell();
    this.root.removeAttribute("aria-busy");

    this.seedOpenDirsFromRoute();
    this.renderSidebar();
    this.renderRoute();
    this.renderStatus();
    this.updateBottomNav();

    this.router.subscribe(() => {
      this.seedOpenDirsFromRoute();
      this.closeMenu();
      withTransition(() => {
        this.renderSidebar();
        this.renderRoute();
        this.renderStatus();
        this.updateBottomNav();
      });
    });

    this.root.addEventListener("click", this.handleClick);
    document.addEventListener("keydown", this.handleKey);
  }

  private get workspaceEl(): HTMLElement | null {
    return this.root.querySelector<HTMLElement>("[data-workspace]");
  }

  private setMenuAria(expanded: boolean): void {
    for (const el of this.root.querySelectorAll<HTMLElement>('[aria-controls="sidebar"]')) {
      el.setAttribute("aria-expanded", String(expanded));
    }
  }

  private openMenu(): void {
    this.workspaceEl?.classList.add("menu-open");
    this.setMenuAria(true);
  }

  private closeMenu(): void {
    this.workspaceEl?.classList.remove("menu-open");
    this.setMenuAria(false);
  }

  private updateBottomNav(): void {
    const nav = this.root.querySelector<HTMLElement>("[data-bottom-nav]");
    if (!nav) return;
    const route = this.router.route;
    const active = route.kind === "home" ? "home" : "files";
    for (const btn of nav.querySelectorAll<HTMLElement>("[data-bn]")) {
      const key = btn.dataset["bn"];
      btn.classList.toggle("active", key === active);
    }
  }

  private seedOpenDirsFromRoute(): void {
    const route = this.router.route;
    if (route.kind === "file") {
      for (const ancestor of ancestorsOf(route.path)) this.openDirs.add(ancestor);
    }
  }

  private renderSidebar(): void {
    const treeEl = this.root.querySelector<HTMLElement>("[data-tree]");
    if (!treeEl) return;
    const activePath = this.router.route.kind === "file" ? this.router.route.path : null;
    treeEl.innerHTML = renderTree(tree, this.openDirs, activePath);
  }

  private renderRoute(): void {
    const editorEl = this.root.querySelector<HTMLElement>("[data-editor]");
    if (!editorEl) return;

    this.disposeCanvas?.();
    this.disposeCanvas = null;

    const route = this.router.route;
    if (route.kind === "home") {
      editorEl.innerHTML = renderWelcome();
      const canvas = editorEl.querySelector<HTMLCanvasElement>("[data-welcome-canvas]");
      if (canvas) this.disposeCanvas = mountWelcomeCanvas(canvas);
      return;
    }
    const file = filesByPath.get(route.path);
    if (!file) {
      editorEl.innerHTML = `
        <div class="not-found" style="view-transition-name: editor;">
          <h2>404</h2>
          <p>${escapeHtml(route.path)} was not found.</p>
          <a class="cta" href="/" data-action="go-home">Back to home</a>
        </div>
      `;
      return;
    }
    editorEl.innerHTML = renderEditor(file);
    const scroller = editorEl.querySelector<HTMLElement>(".walkthrough-scroller, .code-scroller");
    scroller?.scrollTo({ top: 0, behavior: "instant" as ScrollBehavior });
  }

  private renderStatus(): void {
    const statusEl = this.root.querySelector<HTMLElement>("[data-status]");
    if (!statusEl) return;
    statusEl.innerHTML = renderStatusBar(this.router.route);
  }

  private readonly handleClick = (event: MouseEvent): void => {
    const target = event.target;
    if (!(target instanceof Element)) return;

    const actionEl = target.closest<HTMLElement>("[data-action]");
    if (!actionEl) return;

    const action = actionEl.dataset["action"];
    if (action === "toggle-dir") {
      event.preventDefault();
      const dirPath = actionEl.dataset["path"] ?? "";
      if (this.openDirs.has(dirPath)) this.openDirs.delete(dirPath);
      else this.openDirs.add(dirPath);
      withTransition(() => this.renderSidebar());
      return;
    }

    if (action === "open-file") {
      const filePath = actionEl.dataset["path"];
      if (!filePath) return;
      if (event.metaKey || event.ctrlKey || event.shiftKey || event.altKey || event.button !== 0)
        return;
      event.preventDefault();
      this.router.navigate({ kind: "file", path: filePath });
      return;
    }

    if (action === "go-home") {
      event.preventDefault();
      this.router.navigate({ kind: "home" });
      return;
    }

    if (action === "toggle-menu") {
      event.preventDefault();
      if (this.workspaceEl?.classList.contains("menu-open")) this.closeMenu();
      else this.openMenu();
      return;
    }

    if (action === "close-menu") {
      event.preventDefault();
      this.closeMenu();
      return;
    }

    if (action === "focus-search") {
      event.preventDefault();
    }
  };

  private readonly handleKey = (event: KeyboardEvent): void => {
    if (event.key === "Escape" && this.workspaceEl?.classList.contains("menu-open")) {
      event.preventDefault();
      this.closeMenu();
      return;
    }
    if ((event.metaKey || event.ctrlKey) && event.key === "k") {
      event.preventDefault();
    }
  };
}
