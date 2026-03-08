{ config, ... }:

{
  programs.git = {
    enable = true;
    ignores = [
      ".tours"
      ".DS_Store"
      "*.memo.local.md"
      "___naito___"
      ".claude/settings.local.json"
      # VSCode file nesting 用のダミーファイル。プロジェクトルートの設定ファイルをこの下にまとめて視認性を向上させる。
      # 関連: https://github.com/naitokosuke/vscode-settings (explorer.fileNesting.patterns の設定)
      "___config___"
    ];
    settings = {
      user = {
        name = "naitokosuke";
        email = "kosuke.naito.engineer@gmail.com";
      };
      core.editor = "vim";
      init.defaultBranch = "main";
      ghq.root = "${config.home.homeDirectory}/src";
      push.autoSetupRemote = true;
      url."git@github.com:".insteadOf = "https://github.com/";
    };
  };
}
