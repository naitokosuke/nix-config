{
  config,
  pkgs,
  lib,
  ...
}:

{
  # TODO: Replace with nixpkgs package once @playwright/cli is available in nixpkgs
  home.activation.playwrightCli = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export npm_config_prefix="$HOME/.npm-global"
    run mkdir -p "$HOME/.npm-global"
    if [ ! -x "$HOME/.npm-global/bin/playwright-cli" ]; then
      run ${pkgs.nodejs_24}/bin/npm install -g @playwright/cli@latest
    fi
  '';

  home.sessionPath = [ "${config.home.homeDirectory}/.npm-global/bin" ];
}
