# Zsh configuration (login shell)
#
# Zsh is the login shell on macOS, used by:
# - Claude Code (VSCode extension)
# - Other IDE integrations
# - SSH sessions
# - Terminal emulators (as login shell)
#
# Nushell is used as the interactive shell in Ghostty terminal,
# but Zsh handles login shell responsibilities.
#
# PATH is configured in .zprofile (not .zshenv) per Nix best practices.
# See: https://github.com/nix-community/home-manager/issues/2991
{
  config,
  pkgs,
  lib,
  ...
}:

let
  common = import ./common.nix { inherit lib; };
in
{
  programs.zsh = {
    enable = true;

    # Environment variables
    sessionVariables = common.envVars // {
      HOMEBREW_FORBIDDEN_FORMULAE = lib.concatStringsSep " " common.homebrewForbiddenFormulae;
    };

    # PATH configuration (added to .zprofile)
    # profileExtra runs in login shells (terminal, SSH, IDE integrations)
    # Note: .zshenv is not recommended for PATH (see home-manager#2991)
    profileExtra = ''
      # Add paths from common config (last entry becomes first in $PATH)
      ${lib.concatMapStringsSep "\n" (p: "export PATH=\"${p}:$PATH\"") common.pathEntries}
      export PATH="$HOME/.nix-profile/bin:$PATH"
    '';

    # Shell aliases (inherit common + zsh-specific)
    shellAliases = common.aliases // {
      cl = "clear";
    };
  };
}
