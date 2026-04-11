{ config, lib, ... }:
let
  cfg = config.myModules.power;
in
{
  config = lib.mkIf (cfg.enable && cfg.profile == "server") {
    services.logind = {
      lidSwitch = "ignore";
      lidSwitchExternalPower = "ignore";
    };

    systemd.targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };

    powerManagement = {
      cpuFreqGovernor = "performance";
      powertop.enable = false;
    };
  };
}
