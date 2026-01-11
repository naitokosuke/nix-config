{ config, pkgs, ... }:
{

  programs.zsh = {
    enable = true;

    # Define shell aliases
    shellAliases = {
      l = "ls -CF";
      la = "ls -lha";
      ll = "ls -lh";
      cl = "clear";
      ":q" = "exit";
      ".." = "cd ..";
      "..." = "cd ../..";

      # I frequently typo j 😇
      j = "";

      # for antfu/ni
      "に" = "ni";
      nid = "ni -D";
    };

    initContent = ''
            # Initialize prompt
            autoload -Uz promptinit
            promptinit
            # Two-line prompt
            PROMPT='%F{green}%B%n%f at %F{yellow}%m%f in %F{green}%B%~%f
      %F{green}❯%f '

            # History settings
            HISTSIZE=10000
            SAVEHIST=10000
            HISTFILE=~/.zsh_history
            setopt INC_APPEND_HISTORY SHARE_HISTORY

            # Custom functions
            mkcd() {
              mkdir -p "$1" && cd "$1"
            }

            # Default directory on terminal launch
            if [[ -z "$VSCODE_GIT_IPC_HANDLE" && "$TERM_PROGRAM" != "vscode" ]]; then
              cd /Users/naitokosuke/src/github.com/naitokosuke
            fi
    '';
  };
}
