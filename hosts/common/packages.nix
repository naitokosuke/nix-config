{
  inputs,
  pkgs,
  ...
}:

let
  # Not available in nixpkgs, so we build from source
  gwq = pkgs.buildGoModule rec {
    pname = "gwq";
    version = "0.0.19";

    src = pkgs.fetchFromGitHub {
      owner = "d-kuro";
      repo = "gwq";
      rev = "v${version}";
      hash = "sha256-2uE04frxfvQBlrOg5d0hPzGE9sbpzxHEiCeJX1ilG2M=";
    };

    vendorHash = "sha256-4K01Xf1EXl/NVX1loQ76l1bW8QglBAQdvlZSo7J4NPI=";

    # Upstream tests require git in PATH and a writable HOME — skip in the Nix sandbox
    doCheck = false;
  };

  # darwin-rebuild output piped through nix-output-monitor for richer build progress
  darwin-rebuild-nom = pkgs.writeShellApplication {
    name = "darwin-rebuild-nom";
    runtimeInputs = [ pkgs.nix-output-monitor ];
    text = ''
      darwin-rebuild "$@" --log-format internal-json -v 2>&1 | nom --json
    '';
  };
in
{
  environment.systemPackages = with pkgs; [
    bun
    llm-agents.claude-code
    darwin-rebuild-nom
    devenv
    fd
    fzf
    gh
    ghq
    git
    gomi
    gwq
    ni
    nixd
    nix-output-monitor
    nodejs_24
    oxfmt
    pnpm
    ripgrep
    rustup
    sd
    tree
    uv
    vim
    inputs.vize.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.octorus.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.vp.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
