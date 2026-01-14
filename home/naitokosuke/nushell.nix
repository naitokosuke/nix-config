{
  config,
  pkgs,
  lib,
  ...
}:

let
  # nu_scripts for completions
  # https://github.com/nushell/nu_scripts
  nu-scripts = pkgs.fetchFromGitHub {
    owner = "nushell";
    repo = "nu_scripts";
    rev = "main";
    sha256 = "sha256-KfnxoyLY8F0jx6h/SGQb5hkTBHgaa0fktE1qM4BKTBc=";
  };

  # Packages managed by Nix - prevent accidental brew install
  # See: https://github.com/Homebrew/brew/issues/19939
  homebrewForbiddenFormulae = [
    "bun"
    "claude"
    "deno"
    "fd"
    "fzf"
    "gh"
    "git"
    "node"
    "npm"
    "pip"
    "pnpm"
    "python"
    "python3"
    "ripgrep"
    "vim"
    "yarn"
  ];
in
{
  programs.nushell = {
    enable = true;

    # Shell aliases
    shellAliases = {
      l = "ls";
      la = "ls -la";
      ll = "ls -l";
      cl = "^clear"; # External command
      ":q" = "exit";

      # for antfu/ni
      nid = "ni -D";
    };

    # Environment variables
    environmentVariables = {
      EDITOR = "vim";
      HOMEBREW_FORBIDDEN_FORMULAE = lib.concatStringsSep " " homebrewForbiddenFormulae;
    };

    # Extra env configuration (env.nu) - runs before config.nu
    extraEnv = ''
      # Convert PATH from string to list
      $env.PATH = ($env.PATH | split row (char esep))

      # Add paths using std path add (prepends by default)
      use std/util "path add"

      # Standard UNIX paths (add first = lower priority)
      path add "/usr/local/bin"

      # Homebrew (Apple Silicon)
      path add "/opt/homebrew/sbin"
      path add "/opt/homebrew/bin"

      # Nix paths (add last = higher priority)
      path add "/nix/var/nix/profiles/default/bin"
      path add "/run/current-system/sw/bin"
      path add "/etc/profiles/per-user/naitokosuke/bin"
      path add ($env.HOME | path join ".nix-profile" "bin")
    '';

    # Extra configuration (config.nu)
    extraConfig = ''
      # Git completions from nu_scripts
      source ${nu-scripts}/custom-completions/git/git-completions.nu

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
