{
  config,
  pkgs,
  lib,
  ...
}:
let
  # Not available in nixpkgs, so we build from source
  gh-sub-issue = pkgs.buildGoModule rec {
    pname = "gh-sub-issue";
    version = "0.5.1";

    src = pkgs.fetchFromGitHub {
      owner = "yahsan2";
      repo = "gh-sub-issue";
      rev = "v${version}";
      hash = "sha256-WeQFWa+9dPiyInpDQx52vv9VNOzHrcPJi093WG2nmpA=";
    };

    vendorHash = "sha256-U4z6S12j9PBAXHNIQT8GgjEELqc6KTeeSVQnoF9Lw2I=";
  };
in
{
  programs.gh = {
    enable = true;
    extensions = [
      gh-sub-issue
      pkgs.gh-dash
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
