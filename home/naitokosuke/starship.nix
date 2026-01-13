{ config, pkgs, ... }:

{
  programs.starship = {
    enable = true;

    # Enable for Nushell
    enableNushellIntegration = true;

    # Starship configuration
    settings = {
      # Add newline before prompt
      add_newline = true;

      # Prompt format
      format = "$username$hostname$directory$git_branch$git_status$cmd_duration$line_break$character";

      # Character module (prompt indicator)
      character = {
        success_symbol = "[❯](green)";
        error_symbol = "[❯](red)";
      };

      # Username
      username = {
        show_always = true;
        style_user = "green bold";
        format = "[$user]($style) ";
      };

      # Hostname
      hostname = {
        ssh_only = false;
        style = "yellow";
        format = "at [$hostname]($style) ";
      };

      # Directory
      directory = {
        style = "green bold";
        format = "in [$path]($style) ";
        truncation_length = 5;
        truncate_to_repo = false;
      };

      # Git branch
      git_branch = {
        style = "purple bold";
        format = "on [$symbol$branch]($style) ";
      };

      # Git status
      git_status = {
        style = "red bold";
        format = "([$all_status$ahead_behind]($style))";
      };

      # Command duration
      cmd_duration = {
        min_time = 2000;
        style = "yellow";
        format = "took [$duration]($style) ";
      };
    };
  };
}
