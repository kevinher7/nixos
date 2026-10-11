{lib, ...}: {
  services.logind = {
    settings.Login = {
      HandlePowerKey = "suspend";
      HandleLidSwitch = "suspend-then-hibernate";
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
      battery = {
        governor = lib.mkDefault "performance";
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
}
