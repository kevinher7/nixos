{
  config,
  lib,
  ...
}: let
  cfg = config.myModules.power;
in {
  config = lib.mkIf (cfg.enable && cfg.profile == "dell") {
    services.logind = {
      powerKey = "suspend";
      lidSwitch = "suspend-then-hibernate";

      settings.Login = {
        IdleAction = "suspend-then-hibernate";
        IdleActionSec = "10m";
      };
    };

    systemd.sleep.settings.Sleep = {
      HibernateDelaySec = 180;
    };

    services.auto-cpufreq = {
      enable = true;
      settings = {
        # amd-pstate exposes EPP through the `powersave` governor; unlike
        # intel_pstate, pinning `performance` here would ignore the EPP hint
        # entirely and keep the cores boosting on battery.
        battery = {
          governor = "powersave";
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
