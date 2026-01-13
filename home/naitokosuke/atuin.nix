{ config, pkgs, ... }:
{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;

    settings = {
      # Search mode: prefix, fulltext, fuzzy, skim
      search_mode = "fuzzy";

      # Filter mode for search
      filter_mode = "global";

      # Show preview of command
      show_preview = true;

      # Inline height for search UI
      inline_height = 20;

      # Style: auto, full, compact
      style = "compact";
    };
  };
}
