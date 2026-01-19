# zoxide configuration
#
# zoxide is a smarter cd command that learns your habits.
# https://github.com/ajeetdsouza/zoxide
{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.zoxide = {
    enable = true;

    # Enable shell integrations
    enableNushellIntegration = true;
    enableZshIntegration = true;
  };
}
