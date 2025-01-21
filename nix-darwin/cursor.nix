{ config, pkgs, lib, ... }:

{
  system.defaults.NSGlobalDomain.KeyRepeat = 1;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 10;
}
