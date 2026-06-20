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
      # NOTE: "zap"/"uninstall" を指定すると nix-darwin のモジュールが
      # `brew bundle ... --force-cleanup` を生成するが、このフラグは現行の
      # Homebrew (6.x、pin している brew-src 5.1.10 でも) で廃止されており
      # `Error: invalid option: --force-cleanup` でアクティベーションが失敗する。
      # upstream (LnL7/nix-darwin・nix-darwin/nix-darwin の master とも) 未修正のため
      # 自動 cleanup は無効化する。掃除したいときは実際の Brewfile を指定して手動で:
      #   brew bundle cleanup --zap --force --file=<生成されたBrewfile>
      cleanup = "none";
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
