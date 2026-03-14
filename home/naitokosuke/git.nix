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
    ];
    settings = {
      user = {
        name = "naitokosuke";
        email = "kosuke.naito.engineer@gmail.com";
      };
      core.editor = "vim";
      init.defaultBranch = "main";
      ghq.root = "${config.home.homeDirectory}/src";
      push.autoSetupRemote = true;
      url."git@github.com:".insteadOf = "https://github.com/";
    };
  };
}
