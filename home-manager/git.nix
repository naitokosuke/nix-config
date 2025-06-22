{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "naitokosuke";
    userEmail = "kosuke.naito.engineer@gmail.com";
    extraConfig = {
      core.editor = "vim";
      init.defaultBranch = "main";
      ghq.root = "/Users/naitokosuke/src";
      push.autoSetupRemote = true;
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
