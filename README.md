# Nix Configuration for macOS

Personal Nix configuration for macOS using [nix-darwin](https://github.com/LnL7/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager).

## Prerequisites

- macOS on Apple Silicon
- Nix package manager

## Installation

1. Install Nix:
   ```bash
   sh <(curl -L https://nixos.org/nix/install)
   ```

2. Clone this repository:
   ```bash
   git clone https://github.com/naitokosuke/nix-config.git
   cd nix-config
   ```

3. Apply the configuration:
   ```bash
   nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake .#Mac-big
   ```

## Configuration Structure

### System Configuration (`nix-darwin/`)
- `cursor.nix` - Cursor settings
- `dock.nix` - Dock preferences
- `finder.nix` - Finder preferences
- `menubar.nix` - Menu bar settings
- `scroll.nix` - Scrolling behavior
- `screen_capture.nix` - Screen capture settings

### User Configuration (`home-manager/`)
- `gh.nix` - GitHub CLI
- `ghostty.nix` - Ghostty terminal
- `git.nix` - Git configuration
- `zsh.nix` - Zsh shell

### Packages

- **Development**: git, gh, ghq, mise, devbox, uv, pnpm
- **Terminal**: ghostty, vim, fzf, tree
- **macOS utilities**: alt-tab-macos, raycast, superfile
- **Applications**: arc-browser, discord, vscode

*Note: ghostty and arc-browser use pinned nixpkgs versions.*

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