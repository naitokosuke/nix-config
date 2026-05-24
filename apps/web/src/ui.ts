import type { DirNode, FileEntry, TreeNode, WalkthroughSection } from "./types.ts";
import { ancestorsOf, filesByPath, tree } from "./data.ts";
import { highlight, escapeHtml } from "./syntax.ts";
import { iconForFile, icons } from "./icons.ts";
import { Router, routeToHref } from "./router.ts";
import { mountWelcomeCanvas } from "./canvas-bg.ts";

const WELCOME_KEY = "__welcome__";

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

function renderTree(
  node: DirNode,
  openDirs: ReadonlySet<string>,
  activePath: string | null,
): string {
  return node.children.map((child) => renderNode(child, openDirs, activePath, 1)).join("");
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

function renderFileContent(file: FileEntry): string {
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
    <div class="file-view">
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
  // (CC BY 4.0).
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

function renderWelcomeContent(): string {
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
  `;
}

interface TabModel {
  readonly key: string; // file path or WELCOME_KEY
  readonly name: string;
  readonly iconHtml: string;
  readonly href: string;
  readonly isWelcome: boolean;
}

function tabFromFile(file: FileEntry): TabModel {
  return {
    key: file.path,
    name: file.name,
    iconHtml: iconForFile(file.name),
    href: routeToHref({ kind: "file", path: file.path }),
    isWelcome: false,
  };
}

function welcomeTab(): TabModel {
  return {
    key: WELCOME_KEY,
    name: "Welcome",
    iconHtml: icons.sparkle({ size: 14 }),
    href: routeToHref({ kind: "home" }),
    isWelcome: true,
  };
}

function renderTab(tab: TabModel, active: boolean): string {
  const action = tab.isWelcome ? "go-home" : "open-file";
  const pathAttr = tab.isWelcome ? "" : `data-path="${escapeHtml(tab.key)}"`;
  return `
    <div class="tab${active ? " active" : ""}" data-tab-key="${escapeHtml(tab.key)}">
      <a class="tab-link" href="${tab.href}" data-action="${action}" ${pathAttr}>
        <span class="tab-icon">${tab.iconHtml}</span>
        <span class="tab-name">${escapeHtml(tab.name)}</span>
      </a>
      <button class="tab-close" type="button" data-action="close-tab" data-tab-key="${escapeHtml(tab.key)}" aria-label="Close ${escapeHtml(tab.name)}">
        ${icons.close({ size: 12 })}
      </button>
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
          <a class="icon-btn" href="https://twitter.com/naitokosuke" target="_blank" rel="noopener" aria-label="Twitter / @naitokosuke">
            ${icons.twitter()}
          </a>
          <a class="icon-btn" href="https://github.com/naitokosuke/dotfiles" target="_blank" rel="noopener" aria-label="GitHub repository">
            ${icons.github()}
          </a>
          <button
            class="icon-btn"
            type="button"
            data-action="toggle-sidebar"
            aria-controls="sidebar"
            aria-pressed="false"
            aria-label="Toggle sidebar (⌘B)"
            title="Toggle sidebar (⌘B)"
          >
            ${icons.panelRight()}
          </button>
        </div>
      </header>
      <main class="editor">
        <header class="tabs" data-tabs></header>
        <div class="editor-content" data-editor-content></div>
      </main>
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
      <div
        class="sidebar-resizer"
        data-resize-sidebar
        role="separator"
        aria-orientation="vertical"
        aria-label="Resize sidebar"
        title="Drag to resize · double-click to reset"
      ></div>
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
  private readonly openFiles: string[] = [];
  private welcomeOpen = true;
  private disposeCanvas: (() => void) | null = null;

  constructor(root: HTMLElement) {
    this.root = root;
  }

  start(): void {
    this.root.innerHTML = renderShell();
    this.root.removeAttribute("aria-busy");

    this.syncTabsFromRoute();
    this.seedOpenDirsFromRoute();
    this.renderEverything();
    this.initSidebarResize();

    this.router.subscribe(() => {
      this.syncTabsFromRoute();
      this.seedOpenDirsFromRoute();
      this.closeMenu();
      this.renderEverything();
    });

    this.root.addEventListener("click", this.handleClick);
    this.root.addEventListener("auxclick", this.handleAuxClick);
    document.addEventListener("keydown", this.handleKey);
  }

  /**
   * VS Code-style draggable splitter between editor and sidebar,
   * with full collapse / expand support.
   *
   * * Width lives in the `--sidebar-w` custom property on the
   *   workspace; writing to it makes the grid template re-resolve.
   * * Collapsed state is a separate class (`sidebar-collapsed`)
   *   on the workspace — the grid column is forced to 0 and the
   *   sidebar gets `display: none`.
   * * Drag below `COLLAPSE_AT` snaps to collapsed; dragging the
   *   splitter outward from the edge restores width naturally.
   * * Clicking the splitter while collapsed restores the previous
   *   width; ⌘B / Ctrl+B toggles from anywhere.
   * * Width and collapsed flag are persisted to localStorage.
   *
   * Pointer Events + `setPointerCapture` keep the move stream
   * flowing even when the cursor leaves the 6px hit region.
   */
  private initSidebarResize(): void {
    const resizer = this.root.querySelector<HTMLElement>("[data-resize-sidebar]");
    const workspace = this.workspaceEl;
    if (!resizer || !workspace) return;

    const WIDTH_KEY = "naitokosuke-dotfiles:sidebar-w";
    const COLLAPSED_KEY = "naitokosuke-dotfiles:sidebar-collapsed";
    // Single snap threshold for both directions. Below this width the
    // sidebar is closed regardless of pointer position; the moment the
    // pointer crosses outward the sidebar pops in at this width and
    // then tracks the pointer normally. There's no hysteresis "dead
    // zone" — opening is symmetric with closing.
    const SNAP_W = 140;
    const DEFAULT_W = 280;
    const MAX_W = () => Math.min(680, Math.max(SNAP_W, Math.round(window.innerWidth * 0.55)));

    const isCollapsed = () => workspace.classList.contains("sidebar-collapsed");

    /** Write the width as-is (no MIN clamp). Used live, during drag. */
    const setRawWidth = (value: number): number => {
      const v = Math.max(0, Math.min(MAX_W(), Math.round(value)));
      workspace.style.setProperty("--sidebar-w", `${v}px`);
      return v;
    };

    /** Settle the width into the valid [SNAP_W, MAX_W] range and persist. */
    const settleWidth = (value: number): number => {
      const v = Math.max(SNAP_W, Math.min(MAX_W(), Math.round(value)));
      workspace.style.setProperty("--sidebar-w", `${v}px`);
      localStorage.setItem(WIDTH_KEY, String(v));
      return v;
    };

    const setCollapsed = (collapsed: boolean): void => {
      workspace.classList.toggle("sidebar-collapsed", collapsed);
      this.syncSidebarToggleAria();
      localStorage.setItem(COLLAPSED_KEY, collapsed ? "1" : "0");
    };

    this.toggleSidebar = () => setCollapsed(!isCollapsed());

    // Restore persisted state on boot.
    const storedWidth = Number.parseInt(localStorage.getItem(WIDTH_KEY) ?? "", 10);
    if (Number.isFinite(storedWidth)) settleWidth(storedWidth);
    if (localStorage.getItem(COLLAPSED_KEY) === "1") {
      workspace.classList.add("sidebar-collapsed");
      this.syncSidebarToggleAria();
    }

    let startX = 0;
    let startW = 0;
    let dragMoved = false;

    const onPointerDown = (event: PointerEvent) => {
      if (event.button !== 0) return;
      startX = event.clientX;
      if (isCollapsed()) {
        // Drag starts from a fully-collapsed width.
        startW = 0;
      } else {
        const sidebar = this.root.querySelector<HTMLElement>(".sidebar");
        startW = sidebar?.getBoundingClientRect().width ?? DEFAULT_W;
      }
      dragMoved = false;
      resizer.setPointerCapture(event.pointerId);
      resizer.classList.add("is-active");
      document.body.classList.add("resizing-sidebar");
      event.preventDefault();
    };

    /** Visual collapse without persisting — used during live drag. */
    const applyCollapsed = (collapsed: boolean): void => {
      workspace.classList.toggle("sidebar-collapsed", collapsed);
      this.syncSidebarToggleAria();
    };

    const onPointerMove = (event: PointerEvent) => {
      if (!resizer.hasPointerCapture(event.pointerId)) return;
      const dx = event.clientX - startX;
      // Sidebar is on the right edge — dragging *left* widens it.
      const intended = startW - dx;
      if (Math.abs(dx) > 2) dragMoved = true;
      if (!dragMoved) return;

      // Single threshold, symmetric in both directions.
      //   intended <  SNAP_W → closed (no matter how the drag started)
      //   intended >= SNAP_W → open at the pointer's intended width
      if (intended < SNAP_W) {
        if (!isCollapsed()) applyCollapsed(true);
      } else {
        if (isCollapsed()) applyCollapsed(false);
        setRawWidth(intended);
      }
    };

    const onPointerUp = (event: PointerEvent) => {
      if (!resizer.hasPointerCapture(event.pointerId)) return;
      resizer.releasePointerCapture(event.pointerId);
      resizer.classList.remove("is-active");
      document.body.classList.remove("resizing-sidebar");

      // No movement → treat as a click. Toggle.
      if (!dragMoved) {
        this.toggleSidebar?.();
        return;
      }

      // Persist whichever state the drag ended in.
      const finallyCollapsed = isCollapsed();
      localStorage.setItem(COLLAPSED_KEY, finallyCollapsed ? "1" : "0");
      if (!finallyCollapsed) {
        const current = Number.parseInt(workspace.style.getPropertyValue("--sidebar-w"), 10);
        if (Number.isFinite(current)) settleWidth(current);
      }
    };

    const onDoubleClick = () => {
      workspace.style.removeProperty("--sidebar-w");
      localStorage.removeItem(WIDTH_KEY);
      setCollapsed(false);
    };

    resizer.addEventListener("pointerdown", onPointerDown);
    resizer.addEventListener("pointermove", onPointerMove);
    resizer.addEventListener("pointerup", onPointerUp);
    resizer.addEventListener("pointercancel", onPointerUp);
    resizer.addEventListener("dblclick", onDoubleClick);
  }

  private toggleSidebar?: () => void;

  private syncSidebarToggleAria(): void {
    const workspace = this.workspaceEl;
    const btn = this.root.querySelector<HTMLElement>('[data-action="toggle-sidebar"]');
    if (!workspace || !btn) return;
    const collapsed = workspace.classList.contains("sidebar-collapsed");
    // aria-pressed reflects "is the sidebar currently hidden?"
    btn.setAttribute("aria-pressed", String(collapsed));
  }

  private renderEverything(): void {
    this.renderSidebar();
    this.renderTabs();
    this.renderContent();
    this.updateBottomNav();
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

  private syncTabsFromRoute(): void {
    const route = this.router.route;
    if (route.kind === "file") {
      if (!filesByPath.has(route.path)) return;
      if (!this.openFiles.includes(route.path)) this.openFiles.push(route.path);
    } else if (route.kind === "home") {
      // Re-open the Welcome tab if it was closed and the user navigated home.
      this.welcomeOpen = true;
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

  private currentActiveKey(): string {
    const route = this.router.route;
    return route.kind === "file" ? route.path : WELCOME_KEY;
  }

  private buildTabModels(): TabModel[] {
    const tabs: TabModel[] = [];
    if (this.welcomeOpen) tabs.push(welcomeTab());
    for (const path of this.openFiles) {
      const file = filesByPath.get(path);
      if (file) tabs.push(tabFromFile(file));
    }
    return tabs;
  }

  private renderTabs(): void {
    const tabsEl = this.root.querySelector<HTMLElement>("[data-tabs]");
    if (!tabsEl) return;
    const activeKey = this.currentActiveKey();
    const tabs = this.buildTabModels();
    const tabsHtml = tabs.map((tab) => renderTab(tab, tab.key === activeKey)).join("");
    tabsEl.innerHTML = `${tabsHtml}<div class="tabs-spacer"></div>`;

    // Scroll the active tab into view (instant, no animation).
    const activeEl = tabsEl.querySelector<HTMLElement>(`[data-tab-key="${CSS.escape(activeKey)}"]`);
    activeEl?.scrollIntoView({ block: "nearest", inline: "nearest", behavior: "instant" });
  }

  private renderContent(): void {
    const contentEl = this.root.querySelector<HTMLElement>("[data-editor-content]");
    if (!contentEl) return;

    this.disposeCanvas?.();
    this.disposeCanvas = null;

    const route = this.router.route;
    if (route.kind === "home") {
      contentEl.innerHTML = renderWelcomeContent();
      const canvas = contentEl.querySelector<HTMLCanvasElement>("[data-welcome-canvas]");
      if (canvas) this.disposeCanvas = mountWelcomeCanvas(canvas);
      return;
    }
    const file = filesByPath.get(route.path);
    if (!file) {
      contentEl.innerHTML = `
        <div class="not-found">
          <h2>404</h2>
          <p>${escapeHtml(route.path)} was not found.</p>
          <a class="cta" href="/" data-action="go-home">Back to home</a>
        </div>
      `;
      return;
    }
    contentEl.innerHTML = renderFileContent(file);
    const scroller = contentEl.querySelector<HTMLElement>(".walkthrough-scroller");
    scroller?.scrollTo({ top: 0, behavior: "instant" });
  }

  private closeTab(key: string): void {
    const activeKey = this.currentActiveKey();
    let neighbour: string | null = null;

    if (key === WELCOME_KEY) {
      if (!this.welcomeOpen) return;
      this.welcomeOpen = false;
    } else {
      const idx = this.openFiles.indexOf(key);
      if (idx === -1) return;
      this.openFiles.splice(idx, 1);
      if (activeKey === key) {
        neighbour = this.openFiles[idx] ?? this.openFiles[idx - 1] ?? null;
      }
    }

    if (activeKey === key) {
      if (neighbour) {
        this.router.navigate({ kind: "file", path: neighbour });
        return;
      }
      if (this.openFiles.length > 0) {
        const last = this.openFiles[this.openFiles.length - 1];
        if (last) {
          this.router.navigate({ kind: "file", path: last });
          return;
        }
      }
      if (this.welcomeOpen) {
        this.router.navigate({ kind: "home" });
        return;
      }
      // Closing the last remaining tab — re-open Welcome and go home.
      this.welcomeOpen = true;
      this.router.navigate({ kind: "home" });
      return;
    }

    // Closing a non-active tab: keep the current route, just re-render.
    this.renderTabs();
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
      this.renderSidebar();
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

    if (action === "close-tab") {
      event.preventDefault();
      event.stopPropagation();
      const key = actionEl.dataset["tabKey"];
      if (!key) return;
      this.closeTab(key);
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

    if (action === "toggle-sidebar") {
      event.preventDefault();
      this.toggleSidebar?.();
      return;
    }
  };

  private readonly handleAuxClick = (event: MouseEvent): void => {
    if (event.button !== 1) return; // middle-click only
    const target = event.target;
    if (!(target instanceof Element)) return;
    const tab = target.closest<HTMLElement>(".tab");
    if (!tab) return;
    const key = tab.dataset["tabKey"];
    if (!key) return;
    event.preventDefault();
    this.closeTab(key);
  };

  private readonly handleKey = (event: KeyboardEvent): void => {
    if (event.key === "Escape" && this.workspaceEl?.classList.contains("menu-open")) {
      event.preventDefault();
      this.closeMenu();
      return;
    }
    if ((event.metaKey || event.ctrlKey) && event.key === "w") {
      event.preventDefault();
      this.closeTab(this.currentActiveKey());
      return;
    }
    if ((event.metaKey || event.ctrlKey) && (event.key === "b" || event.key === "B")) {
      event.preventDefault();
      this.toggleSidebar?.();
      return;
    }
    if ((event.metaKey || event.ctrlKey) && event.key === "k") {
      event.preventDefault();
    }
  };
}
