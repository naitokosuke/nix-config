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
