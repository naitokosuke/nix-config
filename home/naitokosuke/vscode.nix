{
  inputs,
  pkgs,
  ...
}:
let
  python = pkgs.python3.withPackages (ps: [ ps.json5 ]);
  keybindings-json = pkgs.runCommand "keybindings.json" {
    nativeBuildInputs = [ python ];
  } ''
    python3 -c "
    import json5, json
    data = json5.load(open('${inputs.vscode-settings}/keybinding.jsonc'))
    json.dump(data, open('$out', 'w'), indent=2)
    "
  '';
in
{
  # VSCode settings configuration
  home.file = {
    # Main VSCode settings
    "Library/Application Support/Code/User/settings.json".source =
      "${inputs.vscode-settings}/.vscode/settings.json";

    # Keybindings (converted from JSONC to JSON)
    "Library/Application Support/Code/User/keybindings.json".source = keybindings-json;
  };
}
