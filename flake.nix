{
  description = "naito's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/3187271";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, ... }:
    let
      configuration = { pkgs, ... }: {
        networking.hostName = "Mac-big";

        nixpkgs.config.allowUnfree = true;

        programs.zsh.enable = true;

        environment.systemPackages = with pkgs;
          [
            alt-tab-macos
            arc-browser
            devbox
            discord
            gh
            ghostty
            git
            mise
            raycast
            rectangle
            tree
            vim
            vscode
          ];

        nix.settings.experimental-features = "nix-command flakes";

        system.configurationRevision = self.rev or self.dirtyRev or null;

        system.stateVersion = 5;

        nixpkgs.hostPlatform = "aarch64-darwin";
      };

    in
    {
      darwinConfigurations."naito-naito" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.naito = import ./home-manager/home.nix;
          }
        ] ++ (import ./nix-darwin);
      };

      formatter.aarch64-darwin = inputs.nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
    };
}
