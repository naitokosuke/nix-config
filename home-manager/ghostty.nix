{
  config,
  pkgs,
  lib,
  ...
}:

let
  ghosttyConfig = ''
    theme = "Catppuccin Mocha"
    font-feature = -calt
    font-feature = -dlig
  '';
in
{
  # Ghosttyの設定ファイルを配置
  home.file.".config/ghostty/config".text = ghosttyConfig;
}
