{
  config,
  pkgs,
  lib,
  ...
}:

{
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;
  system.defaults.NSGlobalDomain."AppleShowScrollBars" = "WhenScrolling";
}
