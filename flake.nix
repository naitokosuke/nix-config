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
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Common Darwin system configuration
      mkDarwinConfig =
        { hostName }:
        nix-darwin.lib.darwinSystem {
          modules = (
            [
              {
                networking.hostName = hostName;
                networking.computerName = hostName;

                system.primaryUser = "naitokosuke";

                nixpkgs.config.allowUnfree = true;
                nixpkgs.hostPlatform = system;

                programs.zsh.enable = true;

                environment.systemPackages = with pkgs; [
                  devbox
                  fcp
                  fd
                  fzf
                  gh
                  ghq
                  git
                  mise
                  pnpm
                  ripgrep
                  tree
                  uv
                  vim
                ];

                nix.settings.experimental-features = "nix-command flakes";

                system.configurationRevision = self.rev or self.dirtyRev or null;

                system.stateVersion = 5;
              }
              home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.backupFileExtension = "backup";
                home-manager.users.naitokosuke = import ./home-manager/home.nix;
                home-manager.extraSpecialArgs = {
                  inherit vscode-settings;
                };
              }
              nix-homebrew.darwinModules.nix-homebrew
              {
                nix-homebrew = {
                  enable = true;
                  # Install Homebrew under the default Intel prefix for Rosetta 2
                  enableRosetta = true;
                  user = "naitokosuke";
                  # Automatically migrate existing Homebrew installation
                  autoMigrate = true;
                  taps = {
                    "homebrew/homebrew-cask" = homebrew-cask;
                  };
                  # Declarative tap management
                  mutableTaps = false;
                };
              }
            ]
            ++ (import ./nix-darwin)
          );
        };
    in
    {
      # Mac mini
      darwinConfigurations."Mac-big" = mkDarwinConfig { hostName = "Mac-big"; };

      # MacBook Air
      darwinConfigurations."Macbook-heavy" = mkDarwinConfig { hostName = "Macbook-heavy"; };

      # Use treefmt for formatting with nixfmt
      formatter.${system} = treefmt-nix.lib.mkWrapper pkgs {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
      };
    };
}
