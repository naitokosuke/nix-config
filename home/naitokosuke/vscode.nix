{
  pkgs,
  vscode-settings,
  ...
}:
let
  # Convert JSONC to JSON using Node.js for correct handling of
  # comments inside strings (e.g. URLs with "//"), multi-line block
  # comments, and nested trailing commas.
  jsonc-to-json = pkgs.writeText "jsonc-to-json.js" ''
    const fs = require("fs");
    const input = fs.readFileSync(process.argv[2], "utf8");
    var result = "";
    var inString = false;
    var escape = false;
    for (var i = 0; i < input.length; i++) {
      var ch = input[i];
      if (escape) { result += ch; escape = false; continue; }
      if (inString) {
        if (ch === "\\") { result += ch; escape = true; continue; }
        if (ch === '"') { inString = false; }
        result += ch;
        continue;
      }
      if (ch === '"') { inString = true; result += ch; continue; }
      if (ch === "/" && input[i+1] === "/") {
        while (i < input.length && input[i] !== "\n") i++;
        continue;
      }
      if (ch === "/" && input[i+1] === "*") {
        i += 2;
        while (i < input.length && !(input[i] === "*" && input[i+1] === "/")) i++;
        i++;
        continue;
      }
      result += ch;
    }
    var cleaned = result.replace(/,(\s*[}\]])/g, "$1");
    process.stdout.write(JSON.stringify(JSON.parse(cleaned), null, 2));
  '';

  keybindings-json = pkgs.runCommand "keybindings.json" { } ''
    ${pkgs.nodejs}/bin/node ${jsonc-to-json} ${vscode-settings}/keybinding.jsonc > $out
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
