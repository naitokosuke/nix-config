{
  config,
  inputs,
  ...
}:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.sharedModules = [
    ../../modules/naitokosuke
    inputs.mcp-servers-nix.homeManagerModules.default
  ];
  home-manager.users.${config.naitokosuke.username} = import ../../home;
  home-manager.extraSpecialArgs = {
    inherit inputs;
  };
}
