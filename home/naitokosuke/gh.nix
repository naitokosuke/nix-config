{ config, pkgs, lib, ... }:

{
  programs.gh = {
    enable = true;
    extensions = [
      pkgs.gh-markdown-preview
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

  home.activation.installGhExtensions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.gh}/bin/gh extension install yahsan2/gh-sub-issue 2>/dev/null || true
  '';
}
