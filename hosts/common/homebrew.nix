{
  inputs,
  ...
}:

{
  nix-homebrew = {
    enable = true;
    enableRosetta = false;
    user = "naitokosuke";
    autoMigrate = true;
    taps = {
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
    mutableTaps = true;
  };

  homebrew = {
    enable = true;

    taps = [
      "productdevbook/tap"
    ];

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    casks = [
      "alt-tab"
      "arc"
      "discord"
      "ghostty"
      "google-chrome"
      "obs"
      "obsidian"
      "productdevbook/tap/portkiller"
      "raycast"
      "scroll-reverser"
      "visual-studio-code"
    ];
  };
}
