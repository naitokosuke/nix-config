# Nix Configuration for macOS

This repository contains my personal Nix configuration for macOS using [nix-darwin](https://github.com/LnL7/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager). 
It provides a declarative approach to managing both system-level macOS settings and user-specific configurations.

## Overview

This configuration is designed for Apple Silicon Macs (aarch64-darwin) and includes:

- System-level macOS configurations via nix-darwin
- User-specific configurations via home-manager
- Package management with Nix

## Prerequisites

- macOS running on Apple Silicon (M1/M2/M3)
- Nix package manager installed
- nix-darwin and home-manager

## Installation

1. Install Nix:
   ```bash
   sh <(curl -L https://nixos.org/nix/install)
   ```

2. Enable Nix Flakes:
   ```bash
   mkdir -p ~/.config/nix
   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
   ```

3. Clone this repository:
   ```bash
   git clone https://github.com/engineer-naito/nix-config.git
   cd nix-config
   ```

4. Build and switch to the configuration:
   ```bash
   nix build .#darwinConfigurations.Mac-big.system
   ./result/sw/bin/darwin-rebuild switch --flake .
   ```

## Configuration Structure

### System Configuration (nix-darwin)

The `nix-darwin` directory contains system-level configurations:

- `cursor.nix`: Cursor settings
- `dock.nix`: Dock preferences (autohide, size, magnification)
- `finder.nix`: Finder preferences
- `menubar.nix`: Menu bar settings
- `scroll.nix`: Scrolling behavior
- `screen_capture.nix`: Screen capture settings

### User Configuration (home-manager)

The `home-manager` directory contains user-specific configurations:

- `gh.nix`: GitHub CLI configuration
- `ghostty.nix`: Ghostty terminal configuration (using Catppuccin Mocha theme)
- `git.nix`: Git configuration (user info, default settings, global gitignore)
- `zsh.nix`: Zsh shell configuration (aliases, prompt, history settings)

### Packages

The configuration installs various packages including:

- Development tools: git, gh, mise, devbox, uv, pnpm
- Terminal tools: ghostty, vim, fzf, tree
- macOS utilities: alt-tab-macos, raycast, superfile
- Applications: arc-browser, discord, vscode

## Customization

To customize this configuration for your own use:

1. Update the hostname in `flake.nix`
2. Modify the username and home directory in `home-manager/home.nix`
3. Update personal information in configuration files (e.g., Git user info)
4. Add or remove packages as needed

## Updating

To update the configuration after making changes:

```bash
darwin-rebuild switch --flake .#Mac-big
```
