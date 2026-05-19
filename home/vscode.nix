{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  # Convert JSONC → JSON using Nix builtins (no Python dependency)
  rawContent = builtins.readFile "${inputs.vscode-settings}/keybinding.jsonc";

  # Strip full-line // comments
  lines = lib.splitString "\n" rawContent;
  withoutComments = builtins.filter (line: builtins.match "[[:space:]]*//.*" line == null) lines;
  joined = lib.concatStringsSep "\n" withoutComments;

  # Remove trailing commas before ] or }
  parts = builtins.split ",([[:space:]]*[]}])" joined;
  cleaned = lib.concatStrings (
    map (part: if builtins.isList part then builtins.head part else part) parts
  );

  keybindings-json = pkgs.writeText "keybindings.json" (builtins.toJSON (builtins.fromJSON cleaned));
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
