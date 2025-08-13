{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Explicitly set current default values (as of 2025/08/13)
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
}
