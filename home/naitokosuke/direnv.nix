{ pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    # FIXME: Remove this override once the fix lands in nixpkgs-unstable
    # https://github.com/naitokosuke/dotfiles/pull/283
    # https://github.com/NixOS/nixpkgs/issues/504092
    # https://github.com/NixOS/nixpkgs/pull/502769
    package = pkgs.direnv.overrideAttrs (old: {
      env = (old.env or { }) // {
        CGO_ENABLED = 1;
      };
    });
    nix-direnv.enable = true;
    enableNushellIntegration = true;
  };
}
