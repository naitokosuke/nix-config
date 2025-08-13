{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Explicitly set default values (as of 2025/08/13)
  home.file.".claude/settings.json".text = builtins.toJSON {
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
    env = { };
    todoFeatureEnabled = true;
    messageIdleNotifThresholdMs = 60000;
    autoConnectIde = false;
    autoInstallIdeExtension = true;
    checkpointingEnabled = true;
  };

  # Serena config
  home.file.".serena/serena_config.yml".text = ''
    gui_log_window: false
    web_dashboard: false

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
