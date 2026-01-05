{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Install Rosetta 2 for Intel binary compatibility on Apple Silicon
  # Reference: https://github.com/LnL7/nix-darwin/issues/786
  system.activationScripts.extraActivation.text = ''
    softwareupdate --install-rosetta --agree-to-license || true
  '';
}
