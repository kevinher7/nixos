{ hostname, profile, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/packages.nix
    ../../modules/stylix.nix
    ../../modules/docker.nix
    ../../modules/networking
    ../../modules/containers
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

  myHomelab = {
    vaultwarden = {
      enable = true;
      domain = "https://vault.uribogoat.duckdns.org";
    };

    npm.enable = true;
  };

}

