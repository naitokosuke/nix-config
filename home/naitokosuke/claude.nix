{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Helper: create a writable config file (not a Nix store symlink)
  # Removes leftover symlinks, copies only if file doesn't exist (preserving runtime changes)
  mkWritableConfig =
    {
      dir,
      filename,
      content,
    }:
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      target="${dir}/${filename}"
      run mkdir -p "${dir}"
      [ -L "$target" ] && run rm "$target"
      [ ! -f "$target" ] && run cp ${content} "$target"
    '';
in
{
  # Claude Code settings - writable file, not symlink
  # Claude Code needs write access for resume functionality and session management
  home.activation.claudeSettings = mkWritableConfig {
    dir = "$HOME/.claude";
    filename = "settings.json";
    content = pkgs.writeText "claude-settings.json" (
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
  };

  # Serena config - writable file, not symlink
  # Serena needs write access for runtime configuration
  home.activation.serenaConfig = mkWritableConfig {
    dir = "$HOME/.serena";
    filename = "serena_config.yml";
    content =
      let
        yamlFormat = pkgs.formats.yaml { };
      in
      yamlFormat.generate "serena_config.yml" {
        gui_log_window = false;
        web_dashboard = false;
        projects = { };
      };
  };

  # Claude Code rules and CLAUDE.md - symlink to rule-rule-rule repository
  home.file.".claude/rules".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/src/github.com/${config.home.username}/rule-rule-rule/rules";
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/src/github.com/${config.home.username}/rule-rule-rule/CLAUDE.md";

  # Claude Code skills - symlink to skill-skill-skill repository
  home.file.".claude/skills".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/src/github.com/${config.home.username}/skill-skill-skill";
}
