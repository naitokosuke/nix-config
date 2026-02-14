{
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
  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.trusted-users = [
    "root"
    "naitokosuke"
  ];

  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  system.stateVersion = 5;
}
