{ config, pkgs, ... }: {
  programs.zsh = {
    enable = true;

    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
    };

    initExtra = ''
      export PS1="%F{cyan}%n@%m %F{green}%~ %F{yellow}$%f "

      HISTSIZE=5000
      SAVEHIST=5000
      HISTFILE=~/.zsh_history

      export PATH=$HOME/bin:$PATH
    '';
  };
}
