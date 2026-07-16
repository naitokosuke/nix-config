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
        spinnerVerbs = {
          mode = "replace";
          verbs = [
            "考え中"
            "深く考え中"
            "実装中"
            "リファクタリング中"
            "調査中"
          ];
        };
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
        # Permissions reference:
        #   https://code.claude.com/docs/en/permissions
        #   https://www.claudedirectory.org/blog/claude-code-permissions-guide
        #   https://www.backslash.security/blog/claude-code-security-best-practices
        # Known issue (deny may be ignored on older versions): https://github.com/anthropics/claude-code/issues/6699
        permissions = {
          deny = [
            # Joke: discourage legacy / non-preferred runtimes
            "Bash(perl:*)"
            "Bash(python:*)"
            "Bash(python3:*)"

            # Credentials and secrets (gitignore semantics, recursive)
            "Read(.env)"
            "Read(.env.*)"
            "Read(./secrets/**)"
            "Read(**/credentials.json)"
            "Read(~/.ssh/**)"
            "Read(~/.aws/**)"
            "Read(~/.gnupg/**)"

            # Destructive shell — root / home wipes still trip the circuit breaker,
            # but make it explicit
            "Bash(rm -rf /:*)"
            "Bash(rm -rf ~:*)"
            "Bash(rm -rf ~/:*)"

            # Force-push protection (regular push stays in `ask`/allow)
            "Bash(git push --force:*)"
            "Bash(git push -f:*)"
            "Bash(git push * --force:*)"
            "Bash(git push * -f:*)"

            # Prefer WebFetch with explicit domain over raw curl/wget
            "Bash(curl:*)"
            "Bash(wget:*)"
          ];
        };
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

  # Claude Code skills - link each skill from the skill-skill-skill repository.
  # ~/.claude/skills must stay a real directory: programs.claude-code installs
  # its generated MCP plugin into ~/.claude/skills/claude-code-home-manager,
  # which fails with "outside $HOME" if the directory is itself a symlink.
  # Runs before linkGeneration so the old whole-directory symlink is gone
  # before home-manager links the generated plugin into the directory.
  home.activation.claudeSkills = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
    skillsRepo="${config.home.homeDirectory}/src/github.com/${config.home.username}/skill-skill-skill/.claude/skills"
    skillsDir="$HOME/.claude/skills"
    # Migrate from the previous whole-directory symlink
    [ -L "$skillsDir" ] && run rm "$skillsDir"
    run mkdir -p "$skillsDir"
    # Drop stale links into the repo, then relink every skill
    for link in "$skillsDir"/*; do
      if [ -L "$link" ] && [[ "$(readlink "$link")" == "$skillsRepo"/* ]]; then
        run rm "$link"
      fi
    done
    if [ -d "$skillsRepo" ]; then
      for skill in "$skillsRepo"/*/; do
        run ln -sfn "''${skill%/}" "$skillsDir/$(basename "$skill")"
      done
    fi
  '';
}
