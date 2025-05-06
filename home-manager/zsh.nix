{ config, pkgs, ... }: {

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
      sf = "superfile";

      # I frequently typo j 😇
      j = "";

      # for antfu/ni
      "に" = "ni";
      nid = "ni -D";
    };

    initExtra = ''
      # Initialize prompt
      autoload -Uz promptinit
      promptinit
      PROMPT='%F{green}%B%n%f at %F{magenta}%m%f in %F{blue}%B%~%f %F{red}%B$%f '
      RPROMPT='%F{magenta}[%D{%H:%M:%S}]%f'

      # History settings
      HISTSIZE=10000
      SAVEHIST=10000
      HISTFILE=~/.zsh_history
      setopt INC_APPEND_HISTORY SHARE_HISTORY

      # Custom functions
      mkcd() {
        mkdir -p "$1" && cd "$1"
      }

      # Mise setup
      eval "$(mise activate zsh)"
      export PATH="$HOME/.mise/bin:$PATH"

      # Default directory on terminal launch
      if [[ -z "$VSCODE_GIT_IPC_HANDLE" && "$TERM_PROGRAM" != "vscode" ]]; then
        cd /Users/naitokosuke/src/github.com/naitokosuke
      fi
    '';
  };
}
