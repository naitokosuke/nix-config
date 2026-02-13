{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Claude Code settings - create as real writable file, not symlink
  # home.file creates symlinks to read-only Nix store, but Claude Code needs write access
  # for resume functionality and session management
  home.activation.claudeSettings =
    let
      claudeSettingsContent = pkgs.writeText "claude-settings.json" (
        builtins.toJSON {
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
            DISABLE_INSTALLATION_CHECKS = "1";
          };
          todoFeatureEnabled = true;
          messageIdleNotifThresholdMs = 60000;
          autoConnectIde = false;
          autoInstallIdeExtension = true;
          checkpointingEnabled = true;
          hooks = {
            PreToolUse = [
              {
                matcher = "ExitPlanMode";
                hooks = [
                  {
                    type = "command";
                    command = ''code "$(ls -t ~/.claude/plans/*.md | head -1)"'';
                    timeout = 5;
                  }
                ];
              }
            ];
          };
        }
      );
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      claude_settings="$HOME/.claude/settings.json"
      run mkdir -p "$HOME/.claude"
      # Remove existing file (symlink or regular) before copying
      [ -e "$claude_settings" ] && run rm -f "$claude_settings"
      run cp ${claudeSettingsContent} "$claude_settings"
      run chmod u+w "$claude_settings"
    '';

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

  # Claude Code rules - symlink to rule-rule-rule repository
  home.file.".claude/rules".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/src/github.com/${config.home.username}/rule-rule-rule";

  # Claude Code skills - symlink to skill-skill-skill repository
  home.file.".claude/skills".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/src/github.com/${config.home.username}/skill-skill-skill";

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
