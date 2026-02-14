{
  inputs,
  ...
}:
{
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "naitokosuke";
    autoMigrate = true;
    taps = {
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
    mutableTaps = true;
  };
}
