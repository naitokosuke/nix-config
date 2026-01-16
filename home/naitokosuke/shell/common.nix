# Common shell configuration shared between Nushell and Zsh
#
# This file centralizes settings that should be consistent across shells:
# - PATH configuration
# - Environment variables
# - Homebrew forbidden formulae list
# - Common aliases
#
# Import this in shell-specific modules to avoid duplication.
{ lib, ... }:

{
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

  # Common environment variables
  envVars = {
    EDITOR = "vim";
  };

  # Common shell aliases (POSIX-compatible syntax)
  aliases = {
    l = "ls";
    la = "ls -la";
    ll = "ls -l";
    ":q" = "exit";

    # for antfu/ni
    nid = "ni -D";
  };

  # PATH entries in priority order (last = highest priority)
  # Each shell prepends these in order, so the last entry ends up first in $PATH
  pathEntries = [
    "/usr/local/bin"
    "/opt/homebrew/sbin"
    "/opt/homebrew/bin"
    "/nix/var/nix/profiles/default/bin"
    "/run/current-system/sw/bin"
    "/etc/profiles/per-user/naitokosuke/bin"
    # Note: $HOME/.nix-profile/bin is handled separately in each shell
    # because of different variable expansion syntax
  ];
}
