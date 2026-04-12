{ hostname, profile, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/packages.nix
    ../../modules/programs.nix
    ../../modules/stylix.nix
    ../../modules/desktop/qtile
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

  programs.i3lock.enable = true;
  security.pam.services.i3lock-color.enable = true;
}

