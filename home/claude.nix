{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  # ~/.claude/settings.json must stay a writable real file, not a store
  # symlink: Claude Code writes runtime state into it (model, language,
  # enabledPlugins, plugin hooks, ...). Copying it only when missing kept
  # those runtime edits but silently dropped every later change to the
  # declared settings (issue #361), so the activation instead deep-merges
  # the declared settings into the live file on every rebuild:
  #   - declared keys are authoritative (arrays are replaced wholesale)
  #   - keys that exist only in the live file survive
  claudeSettings = pkgs.writeText "claude-settings.json" (
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
in
{
  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    target="$HOME/.claude/settings.json"
    run mkdir -p "$HOME/.claude"
    # Drop the store symlink left behind by the pre-2026 home.file approach
    [ -L "$target" ] && run rm "$target"
    if [ ! -f "$target" ]; then
      run install -m 644 ${claudeSettings} "$target"
    else
      merged="$HOME/.claude/.settings.json.merged"
      ${lib.getExe pkgs.jq} -s '.[0] * .[1]' "$target" ${claudeSettings} > "$merged"
      if ${pkgs.diffutils}/bin/cmp -s "$merged" "$target"; then
        rm -f "$merged"
      else
        run mv "$merged" "$target"
        rm -f "$merged"
      fi
    fi
  '';

  # Claude Code rules, CLAUDE.md and skills - out-of-store symlinks into the
  # rule-rule-rule / skill-skill-skill repositories.
  #
  # Skills are linked one by one instead of linking ~/.claude/skills itself:
  # programs.claude-code installs its generated MCP plugin into
  # ~/.claude/skills/claude-code-home-manager, which fails with
  # "outside $HOME" when the directory is a symlink.
  home.file =
    let
      ghqRoot = "${config.home.homeDirectory}/src/github.com/${config.home.username}";
      link = path: { source = config.lib.file.mkOutOfStoreSymlink "${ghqRoot}/${path}"; };
      # Skill names are discovered from the locked skill-skill-skill input
      # (pure eval cannot readDir the live working tree). The links themselves
      # still point at the working tree, so skill *content* stays live.
      # After adding/removing a skill: push it, then
      #   nix flake update skill-skill-skill
      skillNames = builtins.attrNames (
        lib.filterAttrs (_: type: type == "directory") (
          builtins.readDir "${inputs.skill-skill-skill}/.claude/skills"
        )
      );
      skillLinks = lib.listToAttrs (
        map (
          name: lib.nameValuePair ".claude/skills/${name}" (link "skill-skill-skill/.claude/skills/${name}")
        ) skillNames
      );
    in
    {
      ".claude/rules" = link "rule-rule-rule/rules";
      ".claude/CLAUDE.md" = link "rule-rule-rule/CLAUDE.md";
    }
    // skillLinks;
}
