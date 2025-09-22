{
  config,
  pkgs,
  lib,
  ...
}:

let
  ghosttyConfig = ''
    theme = "Catppuccin Mocha"
  '';
in
{
  # Ghosttyの設定ファイルを配置
  home.file.".config/ghostty/config".text = ghosttyConfig;
}
