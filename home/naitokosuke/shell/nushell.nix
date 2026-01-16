# Nushell configuration
#
# Nushell is used as the interactive shell in Ghostty terminal.
# Non-POSIX shell with structured data and modern features.
#
# Note: Claude Code and other IDE integrations use zsh (login shell),
# so PATH and environment variables are also configured in zsh.nix.
{
  config,
  pkgs,
  lib,
  ...
}:

let
  common = import ./common.nix { inherit lib; };

  # nu_scripts for completions
  # https://github.com/nushell/nu_scripts
  nu-scripts = pkgs.fetchFromGitHub {
    owner = "nushell";
    repo = "nu_scripts";
    rev = "main";
    sha256 = "sha256-KfnxoyLY8F0jx6h/SGQb5hkTBHgaa0fktE1qM4BKTBc=";
  };
in
{
  programs.nushell = {
    enable = true;

    # Shell aliases (inherit common + nushell-specific)
    shellAliases = common.aliases // {
      cl = "^clear"; # External command (nushell syntax)
    };

    # Environment variables
    environmentVariables = common.envVars // {
      HOMEBREW_FORBIDDEN_FORMULAE = lib.concatStringsSep " " common.homebrewForbiddenFormulae;
    };

    # Extra env configuration (env.nu) - runs before config.nu
    extraEnv = ''
      # Convert PATH from string to list
      $env.PATH = ($env.PATH | split row (char esep))

      # Add paths using std path add (prepends by default)
      use std/util "path add"

      # Add paths from common config
      ${lib.concatMapStringsSep "\n" (p: "path add \"${p}\"") common.pathEntries}
      path add ($env.HOME | path join ".nix-profile" "bin")
    '';

    # Extra configuration (config.nu)
    extraConfig = ''
      # Completions from nu_scripts
      use ${nu-scripts}/custom-completions/git/git-completions.nu *
      use ${nu-scripts}/custom-completions/gh/gh-completions.nu *
      use ${nu-scripts}/custom-completions/nix/nix-completions.nu *
      use ${nu-scripts}/custom-completions/pnpm/pnpm-completions.nu *
      use ${nu-scripts}/custom-completions/rg/rg-completions.nu *

      # Custom function: mkcd
      def mkcd [dir: string] {
        mkdir $dir
        cd $dir
      }

      # Default directory on terminal launch (non-VSCode)
      if ($env.VSCODE_GIT_IPC_HANDLE? | is-empty) and ($env.TERM_PROGRAM? != "vscode") {
        cd /Users/naitokosuke/src/github.com/naitokosuke
      }
    '';
  };
}
