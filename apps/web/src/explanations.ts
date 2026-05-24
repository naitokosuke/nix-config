interface Explanation {
  readonly about: string;
  readonly tags?: readonly string[];
}

export const explanations: Readonly<Record<string, Explanation>> = {
  "README.md": {
    about:
      "Top-level README. Prerequisites, install steps, directory layout, and operational notes.",
    tags: ["docs", "entry"],
  },
  "flake.nix": {
    about:
      "Entry point of the Nix flake. Wires inputs (nixpkgs, nix-darwin, home-manager, nix-homebrew, ...) and assembles darwinConfigurations for Mac-big and Macbook-heavy.",
    tags: ["flake", "entry"],
  },
  "hosts/common/default.nix": {
    about:
      "Aggregates the nix-darwin modules shared across every Mac (dock, finder, homebrew, packages, ...).",
    tags: ["darwin", "index"],
  },
  "hosts/common/dock.nix": {
    about:
      "macOS Dock behaviour — autohide, tile size, magnification, suppression of recent items.",
    tags: ["macos", "ui"],
  },
  "hosts/common/finder.nix": {
    about: "Finder — show extensions, hidden files, column view, path/status bar.",
    tags: ["macos", "ui"],
  },
  "hosts/common/gomi.nix": {
    about: "A launchd user agent that prunes Trash items older than 45 days via gomi (a safer rm).",
    tags: ["launchd", "automation"],
  },
  "hosts/common/home-manager.nix": {
    about:
      "Bridge from nix-darwin to home-manager. Enables useGlobalPkgs / useUserPackages and wires home/naitokosuke/home.nix as the user configuration.",
    tags: ["bridge", "home-manager"],
  },
  "hosts/common/homebrew.nix": {
    about:
      "Declarative Homebrew via nix-homebrew. GUI apps (Arc, Raycast, Ghostty, VS Code, ...) declared as Casks.",
    tags: ["homebrew", "gui"],
  },
  "hosts/common/key_repeat.nix": {
    about: "Fastest macOS key-repeat tuning (KeyRepeat=1, InitialKeyRepeat=20).",
    tags: ["macos", "keyboard"],
  },
  "hosts/common/keyboard.nix": {
    about: "Disables Ctrl+Space / Ctrl+Option+Space input-source switching via symbolichotkeys.",
    tags: ["macos", "keyboard"],
  },
  "hosts/common/menubar.nix": {
    about: "Permanently hides the macOS menu bar to maximise vertical space in fullscreen.",
    tags: ["macos", "ui"],
  },
  "hosts/common/nix.nix": {
    about:
      "Nix runtime — uses Lix, enables flakes / nix-command, schedules GC. Defers /etc Zsh management to home-manager.",
    tags: ["nix", "infra"],
  },
  "hosts/common/packages.nix": {
    about:
      "System-wide CLI packages (git, gh, ripgrep, fd, fzf, pnpm, bun, nodejs, claude-code, vize, vp, octorus, ...) declared in environment.systemPackages.",
    tags: ["cli", "packages"],
  },
  "hosts/common/screen_capture.nix": {
    about: "Pins screenshot output to ~/Pictures/screenshots.",
    tags: ["macos"],
  },
  "hosts/common/scroll.nix": {
    about: "Swipe scroll direction and scrollbar visibility mode.",
    tags: ["macos"],
  },
  "hosts/Mac-big/default.nix": {
    about: "Mac mini (Mac-big) host overrides. Currently a placeholder — no host-specific tweaks.",
    tags: ["host"],
  },
  "hosts/Macbook-heavy/default.nix": {
    about: "MacBook Air (Macbook-heavy) host overrides. Enables Touch ID for sudo.",
    tags: ["host"],
  },
  "home/naitokosuke/home.nix": {
    about:
      "Root of the user-side configuration. Loads CLI tooling modules (atuin, direnv, gh, git, starship, vscode, ...) and sets naitokosuke's home directory.",
    tags: ["home-manager", "index"],
  },
  "home/naitokosuke/atuin.nix": {
    about: "atuin (synced fuzzy shell history). Zsh / Nushell integration and search-mode tuning.",
    tags: ["shell", "history"],
  },
  "home/naitokosuke/claude.nix": {
    about:
      "Claude Code module. Implements a `mkWritableConfig` helper for writable config files, then declares settings.json, hooks, and permissions.",
    tags: ["ai", "claude"],
  },
  "home/naitokosuke/direnv.nix": {
    about:
      "direnv + nix-direnv for per-project env loading. Uses a patched build that forces CGO_ENABLED.",
    tags: ["dev-env"],
  },
  "home/naitokosuke/gh.nix": {
    about:
      "GitHub CLI (gh) configuration and the gh-sub-issue extension built via buildGoModule. Aliases also live here.",
    tags: ["github", "cli"],
  },
  "home/naitokosuke/ghostty.nix": {
    about:
      "Ghostty terminal. Uses the Homebrew-Cask binary, Nushell as the default shell, Catppuccin Mocha as the theme.",
    tags: ["terminal"],
  },
  "home/naitokosuke/git.nix": {
    about:
      "Global git configuration — ignore patterns, aliases, delta-coloured diffs, commit signing.",
    tags: ["git"],
  },
  "home/naitokosuke/gwq.nix": {
    about:
      "gwq (worktree-flavoured ghq) configured via xdg.configFile-generated TOML for a worktree-centric workflow.",
    tags: ["git", "workflow"],
  },
  "home/naitokosuke/mcp.nix": {
    about:
      "MCP (Model Context Protocol) servers. natsukium/mcp-servers-nix as the hub, exposing servers such as Chrome DevTools to Claude Code.",
    tags: ["ai", "mcp"],
  },
  "home/naitokosuke/octorus.nix": {
    about:
      "Octorus (custom GitHub review TUI) configuration — editor, diff theme, key bindings — emitted as TOML.",
    tags: ["github", "review"],
  },
  "home/naitokosuke/playwright.nix": {
    about:
      "Temporary workaround that installs the Playwright CLI into npm-global via home.activation, until nixpkgs ships it.",
    tags: ["test"],
  },
  "home/naitokosuke/starship.nix": {
    about: "Starship prompt — Nushell integration plus newline, glyph, and module-ordering tweaks.",
    tags: ["shell", "prompt"],
  },
  "home/naitokosuke/vscode.nix": {
    about:
      "VS Code settings and keybindings synced from the vscode-settings repo. JSONC is converted to JSON inline via Nix builtins, then placed as writable files.",
    tags: ["editor"],
  },
  "home/naitokosuke/zoxide.nix": {
    about: "zoxide (a learning `cd`). Integrated into Zsh and Nushell.",
    tags: ["shell", "navigation"],
  },
  "home/naitokosuke/shell/default.nix": {
    about: "Shell-config aggregator. Pulls in Nushell (interactive) and Zsh (login) together.",
    tags: ["shell", "index"],
  },
  "home/naitokosuke/shell/common.nix": {
    about:
      "Settings shared between Nushell and Zsh — PATH, env vars, aliases, Homebrew forbidden formulae.",
    tags: ["shell", "common"],
  },
  "home/naitokosuke/shell/nushell.nix": {
    about:
      "Nushell config. The interactive shell inside Ghostty — a structured-data shell with modern ergonomics.",
    tags: ["shell"],
  },
  "home/naitokosuke/shell/zsh.nix": {
    about:
      "Zsh (login shell) config. Used by VS Code extensions, SSH sessions, and IDE-side Claude Code.",
    tags: ["shell"],
  },
  "apps/web/AGENTS.md": {
    about:
      "Agent operating guide for the Vite+ frontend — the `vp install` / `vp check` / `vp test` flow.",
    tags: ["docs", "web"],
  },
};
