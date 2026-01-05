{ ... }:

{
  home.file.".config/ghostty/config".text = ''
    theme = "Catppuccin Mocha"
    font-feature = -calt
    font-feature = -dlig

    # Shift+Enter to insert newline
    # Ghostty implements fixterms, which sends escape sequence [27;2;13~ for Shift+Enter.
    # This breaks multi-line input in Claude Code CLI (which expects a newline character).
    # Rebind Shift+Enter to send \n directly, matching iTerm2's behavior.
    # See: https://github.com/ghostty-org/ghostty/discussions/7780
    keybind = shift+enter=text:\n
  '';
}
