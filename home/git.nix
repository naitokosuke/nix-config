{
  config,
  ...
}:

{
  programs.git = {
    enable = true;
    ignores = [
      ".tours"
      ".DS_Store"
      "*.memo.local.md"
      "___naito___"
      ".claude/settings.local.json"
      # Dummy file for VSCode file nesting. Nests config files under it to reduce clutter in project roots.
      # Related: https://github.com/naitokosuke/vscode-settings (explorer.fileNesting.patterns)
      "___config___"
      # frog friction logs (https://frog.fm) stay local by default. Kept as a
      # directory-level pattern so a repo that wants them tracked can re-include
      # with "!.agents/" in its own .gitignore (issue #385).
      ".agents/"
    ];
    settings = {
      user = {
        name = config.naitokosuke.fullName;
        email = config.naitokosuke.email;
      };
      core.editor = "vim";
      init.defaultBranch = "main";
      ghq.root = "${config.home.homeDirectory}/src";
      push.autoSetupRemote = true;
      url."git@github.com:".insteadOf = "https://github.com/";
    };
  };
}
