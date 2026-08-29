{
  config,
  inputs,
  pkgs,
  ...
}:

{
  # Disable nix-darwin's /etc/zshrc management.
  # Zsh configuration is handled entirely by home-manager.
  # Nushell is the primary interactive shell; Zsh serves as login shell
  # for IDE integrations and SSH sessions.
  programs.zsh.enable = false;

  nix.package = pkgs.lix;

  # Weekly GC keeping the last 14 days of generations as a rollback window.
  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 0;
      Hour = 3;
      Minute = 15;
    };
    options = "--delete-older-than 14d";
  };
  nix.optimise = {
    automatic = true;
    interval = {
      Weekday = 0;
      Hour = 4;
      Minute = 15;
    };
  };

  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.trusted-users = [
    "root"
    config.naitokosuke.username
  ];

  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  system.stateVersion = 5;
}
