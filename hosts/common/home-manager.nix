{
  inputs,
  ...
}:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.naitokosuke = import ../../home/naitokosuke/home.nix;
  home-manager.extraSpecialArgs = {
    inherit inputs;
  };
}
