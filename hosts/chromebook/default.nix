_:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/packages.nix
    ../../modules/networking.nix
    ../../modules/programs.nix
    ../../modules/stylix.nix
    ../../modules/desktop/qtile
    ../../modules/login
    ../../modules/input
    ../../modules/audio
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "beans-btw";

  time.timeZone = "Asia/Tokyo";

  programs.i3lock.enable = true;

  security.pam.services.i3lock-color.enable = true;

  # Power Management
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=5m
  '';

  services.logind = {
    powerKey = "suspend";

    lidSwitch = "suspend-then-hibernate";

    extraConfig = ''
      IdleAction=suspend-then-hibernate
      IdleActionSec=10m
    '';
  };

  services.auto-cpufreq = {
    enable = true;

    settings = {
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
}

