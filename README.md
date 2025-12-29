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
   git clone https://github.com/naitokosuke/nix-config.git
   cd nix-config
   ```

4. Apply the configuration:
   ```bash
   nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake .#Mac-big
   ```

## Configuration Structure

### System Configuration (nix-darwin/)
- `cursor.nix` - Cursor settings
- `dock.nix` - Dock preferences
- `finder.nix` - Finder preferences
- `homebrew.nix` - Homebrew Casks (GUI apps)
- `menubar.nix` - Menu bar settings
- `scroll.nix` - Scrolling behavior
- `screen_capture.nix` - Screen capture settings

### User Configuration (home-manager/)
- `gh.nix` - GitHub CLI
- `ghostty.nix` - Ghostty terminal
- `git.nix` - Git configuration
- `vscode.nix` - VSCode settings sync
- `zsh.nix` - Zsh shell

### Packages

CLI tools are managed via nixpkgs, GUI apps via Homebrew Casks.

**CLI (nixpkgs)**:
- devbox, fcp, fd, fzf, gh, ghq, git, mise, pnpm, ripgrep, tree, uv, vim

**GUI (Homebrew Casks)**:
- alt-tab, arc, discord, ghostty, google-chrome, raycast, scroll-reverser, visual-studio-code

## Customization

1. Update `flake.nix`: hostname, computerName, primaryUser
2. Update `home-manager/home.nix`: username, homeDirectory
3. Update `home-manager/git.nix`: userName, userEmail, ghq.root

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
