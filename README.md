# Nix Configuration for macOS

Personal Nix configuration for macOS using [nix-darwin](https://github.com/LnL7/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager).

## Prerequisites

- macOS on Apple Silicon
- [Lix](https://lix.systems/) package manager
- Xcode Command Line Tools (required for Homebrew)

## Installation

1. Install Xcode Command Line Tools:
   ```bash
   xcode-select --install
   ```

2. Install Lix:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.lix.systems/lix | sh -s -- install
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
├── flake.nix          # Entry point and flake inputs
├── hosts/             # System-level macOS settings (nix-darwin)
│   ├── common/        # Shared settings for all hosts (Dock, Finder, keyboard, etc.)
│   ├── Mac-big/       # Mac mini specific settings
│   └── Macbook-heavy/ # MacBook Air specific settings
└── home/              # User-specific configurations (home-manager)
    └── naitokosuke/
        ├── home.nix   # Main entry point
        └── shell/     # Shell configurations (Nushell, Zsh)
```

See each directory for the full list of modules.

### CLI Packages

Managed via nixpkgs. See [`hosts/common/packages.nix`](hosts/common/packages.nix).

### GUI Apps

Managed via Homebrew Casks. See [`hosts/common/homebrew.nix`](hosts/common/homebrew.nix).

## Customization

1. Update `hosts/common/packages.nix`: Add or remove CLI packages
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

VSCode settings are automatically synchronized from the [vscode-settings](https://github.com/naitokosuke/vscode-settings) repository

- Settings and keybindings are managed through Home Manager
- Existing settings are automatically backed up with `.backup` extension
- JSONC keybindings are converted to JSON format automatically
- Changes to the settings repository are applied with `darwin-rebuild switch`
