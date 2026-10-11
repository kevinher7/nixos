{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.myModules.power.profile == "server") {
    services.logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
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
