# vite-plus (vp) configuration
#
# vp bundles its own Node.js version manager and defaults to "managed" mode, in
# which every vp command runs the toolchain on a Node it downloads into
# ~/.local/share/vite-plus instead of the one on PATH. On a Nix-managed machine
# that is backwards: pkgs/vite-plus.nix already wraps vp with nodejs_26, and
# managed mode both ignores it and accumulates an unmanaged, multi-gigabyte
# runtime store in $HOME.
#
# system_first makes every vp command and shim prefer the Node on PATH, falling
# back to a managed runtime only when none is found. `vp env on` would flip this
# back imperatively, so it is pinned here instead (issue #413).
{ pkgs, ... }:

let
  jsonFormat = pkgs.formats.json { };
in
{
  xdg.configFile."vite-plus/config.json".source = jsonFormat.generate "vite-plus-config.json" {
    shimMode = "system_first";
  };
}
