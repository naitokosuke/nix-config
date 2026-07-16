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

    # TODO: nixpkgs の herdr は Darwin ビルド修正(NixOS/nixpkgs#536015)が
    # nixpkgs-unstable に降りてきたら pkgs.herdr に戻してこの input を削除する
    herdr.url = "github:ogulcancelik/herdr";
    herdr.inputs.nixpkgs.follows = "nixpkgs";

    vize.url = "github:naitokosuke/vize-nix";

    octorus.url = "github:naitokosuke/octorus-nix";

    vp.url = "github:naitokosuke/vp-nix";

    llm-agents.url = "github:numtide/llm-agents.nix";
    llm-agents.inputs.nixpkgs.follows = "nixpkgs";

    mcp-servers-nix.url = "github:natsukium/mcp-servers-nix";
    mcp-servers-nix.inputs.nixpkgs.follows = "nixpkgs";

    nu-scripts = {
      url = "github:nushell/nu_scripts";
      flake = false;
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      nix-darwin,
      home-manager,
      treefmt-nix,
      nix-homebrew,
      llm-agents,
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        localSystem = system;
      };

      hosts = [
        "Mac-big"
        "Macbook-heavy"
      ];

      mkDarwinConfig =
        hostName:
        nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./modules/naitokosuke
            (
              { config, ... }:
              {
                networking.hostName = hostName;
                networking.computerName = hostName;
                system.primaryUser = config.naitokosuke.username;
                nixpkgs.config.allowUnfree = true;
                nixpkgs.hostPlatform = system;
                nixpkgs.overlays = [
                  llm-agents.overlays.shared-nixpkgs
                  # TODO: Remove after nixpkgs fixes nushell test failures in sandbox
                  # https://github.com/NixOS/nixpkgs/issues (nushell 0.112.1 SHLVL tests fail with "Operation not permitted")
                  (final: prev: {
                    nushell = prev.nushell.overrideAttrs (old: {
                      doCheck = false;
                    });
                  })
                  # FIXME: Remove once nixpkgs ships a fix for direnv checkPhase hang on Darwin.
                  # cache.nixos.org serves fish/zsh binaries with broken code signatures, so
                  # macOS Gatekeeper SIGKILLs them during `zsh ./test/direnv-test.zsh`, causing
                  # the build to hang indefinitely.
                  # https://github.com/NixOS/nixpkgs/issues/513019
                  # https://github.com/NixOS/nixpkgs/pull/513081 (proposed fix, not merged)
                  (final: prev: {
                    direnv = prev.direnv.overrideAttrs (old: {
                      doCheck = false;
                    });
                  })
                ];
              }
            )
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            ./hosts/common
            ./hosts/${hostName}
          ];
        };
    in
    {
      darwinConfigurations = nixpkgs.lib.genAttrs hosts mkDarwinConfig;

      formatter.${system} = treefmt-nix.lib.mkWrapper pkgs {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
      };
    };
}
