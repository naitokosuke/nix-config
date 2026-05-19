{
  config,
  inputs,
  ...
}:

{
  nix-homebrew = {
    enable = true;
    enableRosetta = false;
    user = config.naitokosuke.username;
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
      "blender"
      "discord"
      "ghostty"
      "google-chrome"
      "monitorcontrol"
      "obs"
      "obsidian"
      "productdevbook/tap/portkiller"
      "raycast"
      "scroll-reverser"
      "visual-studio-code"
    ];
  };
}
