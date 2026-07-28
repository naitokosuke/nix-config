{
  pkgs,
  ...
}:

{
  programs.gh = {
    enable = true;
    extensions = [
      # Official prebuilt binary from ./pkgs, tracked by nvfetcher
      pkgs.gh-sub-issue
    ];
    settings = {
      version = 1;
      git_protocol = "ssh";
      editor = "vim";
      prompt = "enabled";
      prefer_editor_prompt = "disabled";
      aliases = {
        co = "pr checkout";
      };
    };
  };
}
