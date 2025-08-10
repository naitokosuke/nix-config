{
  config,
  pkgs,
  lib,
  ...
}:

let
  ghosttyConfig = ''
    theme = "catppuccin-mocha"
  '';
in
{
  # Ghosttyの設定ファイルを配置
  home.file.".config/ghostty/config".text = ghosttyConfig;
}
