{
  description = "naito's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # ghostty is broken in nixpkgs-unstable, so use a previous version
    nixpkgs-ghostty.url = "github:NixOS/nixpkgs/3187271";

    # arc-browser is broken in nixpkgs-unstable, so use a previous version
    nixpkgs-arc-browser.url = "github:NixOS/nixpkgs/bd18a43";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-ghostty, nixpkgs-arc-browser, nix-darwin, home-manager, ... }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (final: prev: {
            ghostty = (import nixpkgs-ghostty { inherit system; config.allowUnfree = true; }).ghostty;
            arc-browser = (import nixpkgs-arc-browser { inherit system; config.allowUnfree = true; }).arc-browser;
          })
        ];
      };
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

              environment.systemPackages = with pkgs; [
                alt-tab-macos
                arc-browser
                devbox
                discord
                fzf
                gh
                ghq
                git
                mise
                pnpm
                raycast
                superfile
                tree
                uv
                vim
                vscode
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
              home-manager.users.naitokosuke = import ./home-manager/home.nix;
            }
          ]
          ++ (import ./nix-darwin)
        );
      };

      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}
