{ config, ... }:

{
  system.defaults.screencapture = {
    location = "/Users/${config.system.primaryUser}/Pictures/screen_shots/";
  };
}
