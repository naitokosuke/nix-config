{
  description = "naito's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    vscode-settings.url = "github:naitokosuke/vscode-settings";
    vscode-settings.flake = false;

    vize.url = "github:naitokosuke/vize-nix";

    octorus.url = "github:naitokosuke/octorus-nix";

    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      treefmt-nix,
      nix-homebrew,
      homebrew-cask,
      vscode-settings,
      vize,
      octorus,
      llm-agents,
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        localSystem = system;
        config.allowUnfree = true;
        overlays = [ llm-agents.overlays.default ];
      };

      mkDarwinConfig =
        { hostName }:
        nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit
              self
              vize
              octorus
              vscode-settings
              homebrew-cask
              ;
          };
          modules = [
            {
              networking.hostName = hostName;
              networking.computerName = hostName;
              system.primaryUser = "naitokosuke";
              nixpkgs.config.allowUnfree = true;
              nixpkgs.hostPlatform = system;
              nixpkgs.overlays = [ llm-agents.overlays.default ];
            }
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
          ]
          ++ (import ./hosts/common)
          ++ [ (import ./hosts/${hostName}) ];
        };
    in
    {
      darwinConfigurations."Mac-big" = mkDarwinConfig { hostName = "Mac-big"; };
      darwinConfigurations."Macbook-heavy" = mkDarwinConfig { hostName = "Macbook-heavy"; };

      formatter.${system} = treefmt-nix.lib.mkWrapper pkgs {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
      };
    };
}
