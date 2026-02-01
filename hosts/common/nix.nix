{
  self,
  ...
}:
{
  programs.zsh.enable = false;

  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.trusted-users = [
    "root"
    "naitokosuke"
  ];

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 5;
}
