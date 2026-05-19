{
  config,
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
    ./mcp.nix
    ./octorus.nix
    ./playwright.nix
    ./shell
    ./starship.nix
    ./vscode.nix
    ./zoxide.nix
  ];

  home.username = config.naitokosuke.username;
  home.homeDirectory = lib.mkForce config.naitokosuke.homeDirectory;

  home.stateVersion = "25.05";
}
