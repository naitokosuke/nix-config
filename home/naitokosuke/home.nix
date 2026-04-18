{
  lib,
  ...
}:

{
  imports = [
    ./atuin.nix
    ./claude.nix
    ./direnv.nix
    ./gh.nix
    ./ghostty.nix
    ./git.nix
    ./gwq.nix
    ./octorus.nix
    ./playwright.nix
    ./shell
    ./starship.nix
    ./vscode.nix
    ./zoxide.nix
  ];

  home.username = "naitokosuke";
  home.homeDirectory = lib.mkForce "/Users/naitokosuke";

  home.stateVersion = "25.05";
}
