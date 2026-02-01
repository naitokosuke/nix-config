{ config, pkgs, ... }:
{
  # Remove Taps symlink and create writable directory before homebrew activation
  # extraActivation runs before homebrew in nix-darwin's hardcoded order
  system.activationScripts.extraActivation.text = ''
    TAPS_DIR="/opt/homebrew/Library/Taps"
    # Remove symlink to Nix store if exists
    if [ -L "$TAPS_DIR" ]; then
      rm "$TAPS_DIR"
      mkdir -p "$TAPS_DIR"
      chown naitokosuke:admin "$TAPS_DIR"
    fi
    # Fix permissions if directory exists
    if [ -d "$TAPS_DIR" ]; then
      chown naitokosuke:admin "$TAPS_DIR"
      chmod 755 "$TAPS_DIR"
    fi
  '';

  homebrew = {
    enable = true;

    taps = [
      "productdevbook/tap"
    ];

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
      "productdevbook/tap/portkiller"
      "raycast"
      "scroll-reverser"
      "visual-studio-code"
    ];
  };
}
