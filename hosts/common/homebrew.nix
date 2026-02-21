{ ... }:
{
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
      "obsidian"
      "productdevbook/tap/portkiller"
      "raycast"
      "scroll-reverser"
      "visual-studio-code"
    ];
  };
}
