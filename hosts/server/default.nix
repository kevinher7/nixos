{
  hostname,
  profile,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
    ../../modules/core
    ../../modules/theming
    ../../modules/networking
    ../../modules/login
    ../../modules/power
    ../../modules/secrets
    ../../modules/services
  ];

  time.timeZone = "Asia/Tokyo";

  myModules = {
    networking = {
      enable = true;
      inherit hostname;
      tailscale = {
        enable = true;
        openFirewall = true;
        ssh = true;
      };
    };

    power = {
      enable = true;
      inherit profile;
    };
  };

  myHomelab = {
    npm.enable = true;

    vaultwarden = {
      enable = true;
      domain = "https://vault.uribogoat.duckdns.org";
    };

    pihole = {
      enable = true;
      webPort = "8080";
    };
  };
}
