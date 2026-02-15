{
  inputs,
  pkgs,
  ...
}:
let
  # Node.js script that converts JSONC to JSON by parsing character-by-character,
  # properly handling string boundaries, escaped quotes, and both comment styles.
  jsonc-to-json = pkgs.writeText "jsonc-to-json.js" ''
    const fs = require("fs");
    const input = fs.readFileSync(process.argv[2], "utf8");

    let result = "";
    let i = 0;
    let inString = false;

    while (i < input.length) {
      const ch = input[i];

      if (inString) {
        result += ch;
        if (ch === "\\" ) {
          // Escaped character: copy next char as-is
          i++;
          if (i < input.length) result += input[i];
        } else if (ch === '"') {
          inString = false;
        }
      } else {
        if (ch === '"') {
          inString = true;
          result += ch;
        } else if (ch === '/' && i + 1 < input.length && input[i + 1] === '/') {
          // Single-line comment: skip until end of line
          i += 2;
          while (i < input.length && input[i] !== '\n') i++;
          continue; // don't increment i again at the end
        } else if (ch === '/' && i + 1 < input.length && input[i + 1] === '*') {
          // Multi-line comment: skip until */
          i += 2;
          while (i < input.length && !(input[i] === '*' && i + 1 < input.length && input[i + 1] === '/')) i++;
          i += 2; // skip the closing */
          continue;
        } else {
          result += ch;
        }
      }
      i++;
    }

    // Remove trailing commas before } or ]
    result = result.replace(/,(\s*[}\]])/g, "$1");

    // Validate and pretty-print
    const parsed = JSON.parse(result);
    fs.writeFileSync(process.argv[3], JSON.stringify(parsed, null, 2) + "\n");
  '';

  # Convert JSONC to JSON using the Node.js parser
  keybindings-json = pkgs.stdenvNoCC.mkDerivation {
    name = "keybindings.json";
    nativeBuildInputs = [ pkgs.nodejs-slim ];
    dontUnpack = true;
    buildCommand = ''
      node ${jsonc-to-json} ${inputs.vscode-settings}/keybinding.jsonc $out
    '';
  };
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
