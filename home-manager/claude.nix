{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Explicitly set default values (as of 2025/08/13) - only create if it doesn't exist
  home.file.".claude/settings.json" = {
    text = builtins.toJSON {
      installMethod = "unknown";
      autoUpdates = true;
      theme = "dark-daltonized";
      verbose = false;
      preferredNotifChannel = "auto";
      shiftEnterKeyBindingInstalled = true;
      editorMode = "normal";
      hasUsedBackslashReturn = true;
      autoCompactEnabled = true;
      diffTool = "auto";
      env = {
        DISABLE_AUTOUPDATER = "1";
      };
      todoFeatureEnabled = true;
      messageIdleNotifThresholdMs = 60000;
      autoConnectIde = false;
      autoInstallIdeExtension = true;
      checkpointingEnabled = true;
    };
    # Only create if file doesn't exist, allowing Claude Code to manage it
    force = false;
  };

  # Serena config - create as real writable file, not symlink
  # home.file creates symlinks to read-only Nix store, but Serena needs write access
  home.activation.serenaConfig =
    let
      serenaConfigContent = pkgs.writeText "serena_config.yml" ''
        gui_log_window: false
        web_dashboard: false
        projects: {}
      '';
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      serena_config="$HOME/.serena/serena_config.yml"
      run mkdir -p "$HOME/.serena"
      [ -L "$serena_config" ] && run rm "$serena_config"
      [ ! -f "$serena_config" ] && run cp ${serenaConfigContent} "$serena_config"
    '';

  # Global Claude Code memory
  home.file.".claude/CLAUDE.md".text = ''
    # Package Management

    ## JavaScript/Node.js Projects

    **Always** use `@antfu/ni` - use the right package manager.

    ### Why use `@antfu/ni`?

    > npm i in a yarn project, again? F**k!
    > ni - use the right package manager

    ### Commands

    - `ni` instead of npm/yarn/pnpm install
    - `nr <script>` for running scripts

  '';
}
