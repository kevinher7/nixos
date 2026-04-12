{ config, lib, ... }:
let
  cfg = config.myModules.power;
in
{
  config = lib.mkIf (cfg.enable && cfg.profile == "chromebook") {
    services.logind = {
      powerKey = "suspend";
      lidSwitch = "suspend-then-hibernate";

      extraConfig = ''
        IdleAction=suspend-then-hibernate
        IdleActionSec=10m
      '';
    };

    systemd.sleep.extraConfig = ''
      HibernateDelaySec=180
    '';

    services.auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "performance";
          turbo = "auto";
          energy_performance_preference = "power";
        };

        charger = {
          governor = "performance";
          turbo = "auto";
          energy_performance_preference = "balance_performance";
        };
      };
    };
  };
}
