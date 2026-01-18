# Nix Configuration for macOS

Personal Nix configuration for macOS using [nix-darwin](https://github.com/LnL7/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager).

## Prerequisites

- macOS on Apple Silicon
- Nix package manager
- Xcode Command Line Tools (required for Homebrew)

## Installation

1. Install Xcode Command Line Tools:
   ```bash
   xcode-select --install
   ```

2. Install Nix:
   ```bash
   sh <(curl -L https://nixos.org/nix/install)
   ```

3. Clone this repository:
   ```bash
   git clone https://github.com/naitokosuke/dotfiles.git
   cd dotfiles
   ```

4. Apply the configuration:
   ```bash
   nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake .#Mac-big
   ```

## Configuration Structure

```
.
├── flake.nix          # Entry point with package lists and system configuration
├── hosts/             # System-level macOS settings (nix-darwin)
│   ├── common/        # Shared settings for all hosts
│   ├── Mac-big/       # Mac mini specific settings
│   └── Macbook-heavy/ # MacBook Air specific settings
└── home/              # User-specific configurations (home-manager)
    └── naitokosuke/
        ├── home.nix   # Main entry point
        ├── shell/     # Shell configurations (Nushell, Zsh)
        └── ...        # Other modules (git, gh, vscode, etc.)
```

### System Configuration (hosts/common/)

- `cursor.nix` - Cursor settings
- `dock.nix` - Dock preferences
- `finder.nix` - Finder preferences
- `homebrew.nix` - Homebrew Casks (GUI apps)
- `keyboard.nix` - Keyboard settings
- `menubar.nix` - Menu bar settings
- `rosetta.nix` - Rosetta 2 for Intel compatibility
- `screen_capture.nix` - Screen capture settings
- `scroll.nix` - Scrolling behavior

### User Configuration (home/naitokosuke/)

- `shell/nushell.nix` - Nushell (primary shell)
- `shell/zsh.nix` - Zsh (fallback shell)
- `atuin.nix` - Shell history with Atuin
- `claude.nix` - Claude Code configuration
- `direnv.nix` - Directory-based environments
- `gh.nix` - GitHub CLI
- `ghostty.nix` - Ghostty terminal
- `git.nix` - Git configuration
- `starship.nix` - Starship prompt
- `vscode.nix` - VSCode settings sync

### Packages

CLI tools are managed via nixpkgs, GUI apps via Homebrew Casks.

**CLI (nixpkgs)**:
- bun, claude-code, deno, devbox, devenv, fcp, fd, fzf, gh, ghq, git, gomi, ni, nodejs, pnpm, ripgrep, rustup, tree, uv, vim

**GUI (Homebrew Casks)**:
- alt-tab, arc, discord, ghostty, google-chrome, raycast, scroll-reverser, visual-studio-code

## Customization

1. Update `flake.nix`: Add packages to `environment.systemPackages`
2. Update `hosts/common/`: Add or modify system settings
3. Update `home/naitokosuke/`: Add or modify user configurations

## Usage

Apply configuration changes:
```bash
darwin-rebuild switch --flake .#Mac-big
```

Update flake inputs:
```bash
nix flake update
darwin-rebuild switch --flake .#Mac-big
```

## VSCode Settings Sync

VSCode settings are automatically synchronized from the [vscode-settings](https://github.com/naitokosuke/vscode-settings) repository:

- Settings and keybindings are managed through Home Manager
- Existing settings are automatically backed up with `.backup` extension
- JSONC keybindings are converted to JSON format automatically
- Changes to the settings repository are applied with `darwin-rebuild switch`
