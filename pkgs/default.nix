# Custom packages for tools not available in nixpkgs (issue #342).
# Versions and hashes are tracked by nvfetcher — see nvfetcher.toml.
{ pkgs }:
let
  sources = pkgs.callPackage ./_sources/generated.nix { };
in
{
  ax = pkgs.callPackage ./ax.nix { inherit sources; };
  octorus = pkgs.callPackage ./octorus.nix { inherit sources; };
  vite-plus = pkgs.callPackage ./vite-plus.nix { inherit sources; };
  vize = pkgs.callPackage ./vize.nix { inherit sources; };
}
