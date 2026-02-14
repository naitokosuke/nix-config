{
  inputs,
  ...
}:
let
  inherit (inputs) homebrew-cask;
in
{
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "naitokosuke";
    autoMigrate = true;
    taps = {
      "homebrew/homebrew-cask" = homebrew-cask;
    };
    mutableTaps = true;
  };
}
