# Style and Conventions

## Nix Module Structure

Each nix module follows this pattern:

```nix
{ config, pkgs, ... }: {
  # configuration attributes
}
```

## Adding New Configurations

1. **System Settings**: Create `.nix` file in `nix-darwin/`, add to `default.nix` imports
2. **User Configurations**: Create `.nix` file in `home-manager/`, import in `home.nix`

## Package Management

- System packages: Add to `environment.systemPackages` in `flake.nix`
- Broken packages: Use pinned nixpkgs versions via overlays

## Documentation Standards

- Use `-` for bullet points (not `*`)
- Use single `#` per file
- Add blank lines after `##` and `###` headings
- Add spaces between half-width characters and Japanese text
- Use half-width parentheses `()`
