{
  pkgs,
  vscode-settings,
  ...
}:
let
  # Convert JSONC to JSON by removing comments and trailing commas
  keybindings-json = pkgs.runCommand "keybindings.json" { } ''
    # Install jq for JSON processing
    export PATH=${pkgs.jq}/bin:$PATH

    # Convert JSONC to JSON
    # Remove comments and trailing commas, then format as valid JSON
    cat ${vscode-settings}/keybinding.jsonc \
      | sed 's|//.*||g' \
      | sed 's|/\*.*\*/||g' \
      | tr -d '\n' \
      | sed 's/,\s*}/}/g' \
      | sed 's/,\s*]/]/g' \
      | jq . > $out
  '';
in
{
  # VSCode settings configuration
  home.file = {
    # Main VSCode settings
    "Library/Application Support/Code/User/settings.json".source =
      "${vscode-settings}/.vscode/settings.json";

    # Keybindings (converted from JSONC to JSON)
    "Library/Application Support/Code/User/keybindings.json".source = keybindings-json;
  };

}
