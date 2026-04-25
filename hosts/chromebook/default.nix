{ hostname, profile, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/packages.nix
    ../../modules/stylix.nix
    ../../modules/desktop/qtile
    ../../modules/system
    ../../modules/networking
    ../../modules/login
    ../../modules/power
    ../../modules/input
    ../../modules/audio
  ];

  time.timeZone = "Asia/Tokyo";

  myModules = {
    networking = {
      enable = true;
      hostname = hostname;
      tailscale = {
        enable = true;
        ssh = false;
      };
    };

    power = {
      enable = true;
      profile = profile;
    };
  };

  programs = {
    i3lock.enable = true;
    light.enable = true;
  };

  security.pam.services.i3lock-color.enable = true;
}

