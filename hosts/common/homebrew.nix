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
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "productdevbook/homebrew-tap" = inputs.homebrew-productdevbook;
    };
    # Taps are read-only and pinned by flake.lock; `brew tap` is disabled.
    mutableTaps = false;
  };

  homebrew = {
    enable = true;

    # Mirror the nix-homebrew-pinned taps into the Brewfile so
    # `brew bundle` cleanup does not try to untap them.
    taps = builtins.attrNames config.nix-homebrew.taps;

    # Fully declarative (issue #363): cask definitions come from the
    # flake-pinned taps (HOMEBREW_NO_INSTALL_FROM_API), so activation
    # converges installed apps to what flake.lock pins — new versions arrive
    # via `nix flake update` + rebuild, and casks removed from the list below
    # are uninstalled. Most of these apps still self-update independently.
    onActivation = {
      autoUpdate = false;
      upgrade = true;
      cleanup = "uninstall";
      extraEnv = {
        HOMEBREW_NO_INSTALL_FROM_API = "1";
      };
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
