# Shell configurations aggregator
#
# Manages both Nushell (interactive terminal) and Zsh (login shell for IDE/CLI tools).
# Common settings (PATH, env vars, aliases) are defined in common.nix.
{ ... }:

{
  imports = [
    ./nushell.nix
    ./zsh.nix
  ];
}
