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

- flake.nix: Entry point defining the Darwin system configuration. Contains package lists and system settings.
- nix-darwin/: System-level macOS settings (dock, finder, cursor, etc.)
  - Each module exports specific macOS system preferences
  - Imported via `default.nix` which aggregates all modules
- home-manager/: User-specific configurations
  - `home.nix`: Main entry point that imports other modules
  - Individual modules for git, zsh, ghostty terminal, GitHub CLI

## Key Development Patterns

1. Adding System Settings: Create a new `.nix` file in `nix-darwin/` and add it to the imports in `default.nix`

2. Adding User Configurations: Create a new `.nix` file in `home-manager/` and import it in `home.nix`

3. Package Management: 
   - System packages: Add to `environment.systemPackages` in flake.nix:36-65
   - Broken packages use pinned nixpkgs versions via overlays (see ghostty/arc-browser in flake.nix:26-31)

4. Module Structure: Each nix module typically follows:
   ```nix
   { config, pkgs, ... }: {
     # configuration attributes
   }
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

- Hostname: "Mac-big" (defined in flake.nix:39)
- User: "naitokosuke" (referenced in flake.nix:77)
- System: "aarch64-darwin" (Apple Silicon)
- Experimental features enabled: nix-command, flakes
