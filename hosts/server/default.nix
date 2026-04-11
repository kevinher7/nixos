{ hostname, profile, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/packages.nix
    ../../modules/docker.nix
    ../../modules/desktop/qtile
    ../../modules/networking
    ../../modules/login
    ../../modules/power
  ];

  time.timeZone = "Asia/Tokyo";

  myModules = {
    networking = {
      enable = true;
      hostname = hostname;
      tailscale = {
        enable = true;
        openFirewall = true;
        ssh = true;
      };
    };

    power = {
      enable = true;
      profile = profile;
    };
  };
}

