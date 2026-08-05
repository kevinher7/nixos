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
        # Clamshell: systemd counts any connected HDMI/DP monitor as "docked",
        # so lid close with the external monitor attached does nothing.
        # If the laptop still suspends while the monitor is attached (known
        # systemd docked-detection race), also set HandleLidSwitchExternalPower = "ignore".
        HandleLidSwitchDocked = "ignore";
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
