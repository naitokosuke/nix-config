{
  description = "naito's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # arc-browser was removed from nixpkgs as unmaintained, so use a pinned version
    nixpkgs-arc-browser.url = "github:NixOS/nixpkgs/bd18a43";

    # ghostty is not available on aarch64-darwin in latest nixpkgs, so use a pinned version
    nixpkgs-ghostty.url = "github:NixOS/nixpkgs/3187271";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    vscode-settings.url = "github:naitokosuke/vscode-settings";
    vscode-settings.flake = false;
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-arc-browser,
      nixpkgs-ghostty,
      nix-darwin,
      home-manager,
      treefmt-nix,
      vscode-settings,
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      arc-browser =
        (import nixpkgs-arc-browser {
          inherit system;
          config.allowUnfree = true;
        }).arc-browser;
      ghostty =
        (import nixpkgs-ghostty {
          inherit system;
          config.allowUnfree = true;
        }).ghostty;
    in
    {
      darwinConfigurations."Mac-big" = nix-darwin.lib.darwinSystem {
        modules = (
          [
            {
              networking.hostName = "Mac-big";
              networking.computerName = "Mac-big";

              system.primaryUser = "naitokosuke";

              nixpkgs.config.allowUnfree = true;
              nixpkgs.hostPlatform = system;

              programs.zsh.enable = true;

              environment.systemPackages =
                (with pkgs; [
                  alt-tab-macos
                  devbox
                  discord
                  fcp
                  fd
                  fzf
                  gh
                  ghq
                  git
                  google-chrome
                  mise
                  pnpm
                  raycast
                  ripgrep
                  scroll-reverser
                  tree
                  uv
                  vim
                  vscode
                ])
                ++ [
                  arc-browser
                  ghostty
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
          ]
          ++ (import ./nix-darwin)
        );
      };

      # Use treefmt for formatting with nixfmt
      formatter.${system} = treefmt-nix.lib.mkWrapper pkgs {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
      };
    };
}
