{ config, pkgs, ... }:
{
  launchd.user.agents.gomi-prune = {
    serviceConfig = {
      ProgramArguments = [
        "/run/current-system/sw/bin/gomi"
        "--prune=45d,orphans"
      ];
      StartCalendarInterval = [
        {
          Weekday = 0;
          Hour = 3;
        }
      ];
      StandardOutPath = "/tmp/gomi-prune.log";
      StandardErrorPath = "/tmp/gomi-prune.log";
    };
  };
}
