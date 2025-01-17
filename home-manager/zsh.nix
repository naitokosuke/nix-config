{ config, pkgs, ... }: {

  programs.zsh = {
    enable = true;

    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
    };

    initExtra = ''
      # Prompt
      autoload -Uz promptinit
      promptinit
      PROMPT='%F{cyan}%n@%m %F{green}%~ %F{yellow}$%f '
      RPROMPT='%F{magenta}[%D{%H:%M:%S}]%f'

      # History settings
      HISTSIZE=10000
      SAVEHIST=10000
      HISTFILE=~/.zsh_history
      setopt INC_APPEND_HISTORY SHARE_HISTORY

      # Aliases
      alias ll='ls -lh'
      alias la='ls -lha'
      alias gs='git status'
      alias gc='git commit'
      alias gp='git push'
      alias ..='cd ..'

      # Custom functions
      mkcd() {
        mkdir -p "$1" && cd "$1"
      }

      # Mise setup
      if [ -x "$(command -v mise)" ]; then
        eval "$(mise activate zsh)"
      else
        echo "Mise is not installed or not in PATH."
      fi
    '';
  };
}
