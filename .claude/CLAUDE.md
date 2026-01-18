# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Nix configuration repository for macOS that uses:
- nix-darwin: System-level macOS configurations
- home-manager: User-specific configurations
- Nix Flakes: Reproducible dependency management

The configuration targets Apple Silicon Macs (aarch64-darwin) and manages both system settings and user environments declaratively.

## Common Commands

### Apply Configuration Changes
```bash
darwin-rebuild switch --flake .#Mac-big
```

### Format Nix Files
```bash
nix fmt
```

### Update Flake Inputs
```bash
nix flake update
```

## Architecture

The codebase follows a modular structure:

```
.
├── flake.nix          # Entry point with package lists and system configuration
├── hosts/             # System-level macOS settings (nix-darwin)
│   ├── common/        # Shared settings for all hosts
│   │   ├── cursor.nix
│   │   ├── dock.nix
│   │   ├── finder.nix
│   │   ├── homebrew.nix
│   │   ├── keyboard.nix
│   │   ├── menubar.nix
│   │   ├── rosetta.nix
│   │   ├── screen_capture.nix
│   │   └── scroll.nix
│   ├── Mac-big/       # Mac mini specific settings
│   └── Macbook-heavy/ # MacBook Air specific settings
└── home/              # User-specific configurations (home-manager)
    └── naitokosuke/
        ├── home.nix   # Main entry point
        ├── atuin.nix  # Shell history with Atuin
        ├── claude.nix # Claude Code configuration
        ├── direnv.nix # Directory-based environments
        ├── gh.nix     # GitHub CLI
        ├── ghostty.nix# Ghostty terminal
        ├── git.nix    # Git configuration
        ├── starship.nix # Starship prompt
        ├── vscode.nix # VSCode settings sync
        └── shell/     # Shell configurations
            ├── nushell.nix  # Nushell (primary shell)
            └── zsh.nix      # Zsh (fallback)
```

## Key Development Patterns

1. Adding System Settings: Create a new `.nix` file in `hosts/common/` and add it to the imports in `default.nix`

2. Adding User Configurations: Create a new `.nix` file in `home/naitokosuke/` and import it in `home.nix`

3. Package Management:
   - System packages: Add to `environment.systemPackages` in flake.nix (around line 71-95)
   - GUI apps: Add to Homebrew Casks in `hosts/common/homebrew.nix`

4. Module Structure: Each nix module typically follows:
   ```nix
   { config, pkgs, ... }: {
     # configuration attributes
   }
   ```

## GitHub Workflow

Use `gh` CLI for all issue, branch, and PR operations.

### Issue Management

- Use `gh issue` commands for creating and managing issues
- Use `gh sub issue` extension for creating sub-issues

### Branch Naming Convention

Work branches **must** be prefixed with the issue number:

```bash
# Example: branch for issue #42
git checkout -b 42-add-new-feature
```

### Pull Request Creation

Follow these rules when creating PRs:

1. Use `gh pr create` command
2. Include `Closes #<issue-number>` in the PR body to auto-close the issue on merge

```bash
# Example
gh pr create --title "Add new feature" --body "Closes #42"
```

## Documentation Standards

When creating markdown documentation, follow the rules defined in `~/src/github.com/naitokosuke/airules/markdown-writing-rules.md`:
- Use `-` for bullet points (not `*`)
- Use single `#` per file
- Add blank lines after `##` and `###` headings
- Add spaces between half-width characters and Japanese text
- Use half-width parentheses `()`
- Use emphasis (`**bold**`) sparingly and only for special emphasis

## Important Configuration Details

- Hosts: "Mac-big" (Mac mini), "Macbook-heavy" (MacBook Air)
- User: "naitokosuke"
- System: "aarch64-darwin" (Apple Silicon)
- Primary shell: Nushell (with Zsh as fallback)
- Experimental features enabled: nix-command, flakes

## VSCode Settings Sync

The repository includes automatic VSCode settings synchronization from GitHub repository `naitokosuke/vscode-settings`:

- Module: `home/naitokosuke/vscode.nix`
- Settings Path: `~/Library/Application Support/Code/User/settings.json`
- Keybindings Path: `~/Library/Application Support/Code/User/keybindings.json`
- Backup: Existing files are automatically backed up with `.backup` extension
- JSONC Support: Keybindings are converted from JSONC to JSON format automatically

### Updating VSCode Settings

1. Modify settings in the `vscode-settings` repository
2. Run `nix flake update` to fetch latest changes (optional)
3. Run `darwin-rebuild switch --flake .#Mac-big` to apply changes
