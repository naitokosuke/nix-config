{
  pkgs,
  vize,
  ...
}:
{
  environment.systemPackages =
    with pkgs;
    [
      bun
      claude-code
      deno
      devbox
      devenv
      fcp
      fd
      fzf
      gh
      ghq
      git
      gomi
      ni
      nodejs_24
      pnpm
      ripgrep
      rustup
      tree
      uv
      vim
    ]
    ++ [ vize.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
