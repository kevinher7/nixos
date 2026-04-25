{ hostname, profile, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/packages.nix
    ../../modules/stylix.nix
    ../../modules/secrets/sops.nix
    ../../modules/networking
    ../../modules/login
    ../../modules/power
    ../../modules/services
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
    npm.enable = true;

    # vaultwarden = {
    #   enable = true;
    #   domain = "https://vault.uribogoat.duckdns.org";
    # };
    #
    pihole = {
      enable = true;
      webPort = "8080";
    };
  };

}

