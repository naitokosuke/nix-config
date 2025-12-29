{ config, pkgs, ... }:
{
  homebrew = {
    enable = true;

    onActivation = {
      # Do not auto-update Homebrew during darwin-rebuild
      autoUpdate = false;
      # Do not upgrade already installed packages
      upgrade = false;
      # Do not remove packages not listed here (safe default)
      cleanup = "none";
    };

    casks = [
      "alt-tab"
      "arc"
      "discord"
      "ghostty"
      "google-chrome"
      "raycast"
      "scroll-reverser"
      "visual-studio-code"
    ];
  };
}
