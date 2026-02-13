{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
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

  home.file = {
    ".config/git/ignore".text = ''
      .tours
      .DS_Store
      *.memo.local.md
      ___naito___
    '';
  };
}
