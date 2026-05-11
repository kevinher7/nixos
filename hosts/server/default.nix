{
  hostname,
  profile,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
    ../../modules/core
    ../../modules/theming
    ../../modules/networking
    ../../modules/power
    ../../modules/secrets
    ../../modules/services
  ];

  time.timeZone = "Asia/Tokyo";

  networking = {
    useDHCP = lib.mkForce false;

    # Tell NetworkManager not to touch enp2s0; we manage it declaratively
    networkmanager.unmanaged = ["enp2s0"];

    interfaces.enp2s0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.0.2";
          prefixLength = 24;
        }
      ];
    };

    defaultGateway = {
      address = "192.168.0.1";
      interface = "enp2s0";
    };

    # Fallback DNS for the server
    nameservers = ["1.1.1.1" "8.8.8.8"];
  };

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
    nginxProxy.enable = true;
    homepage.enable = true;

    vaultwarden = {
      enable = true;
      domain = "https://vault.uribogoat.duckdns.org";
    };

    pihole = {
      enable = true;
      webPort = "8080";
      localDomainIP = "100.87.121.69";

      localHosts = [
        "192.168.0.1   router.lan"
        "192.168.0.2   server.lan"
      ];

      upstreamDNS = ["1.1.1.1" "1.0.0.1" "8.8.8.8"];

      dhcp = {
        enable = true;
        active = true;
        router = "192.168.0.1";
        start = "192.168.0.100";
        end = "192.168.0.250";

        # Add static leases here if you have devices needing fixed IPs
        staticLeases = [
          # Format: "MAC_ADDRESS,IP,hostname,leaseTime"
          # Example: "aa:bb:cc:dd:ee:ff,192.168.0.10,nas,infinite"
        ];
      };

      openFirewallDHCP = true;
    };
  };
}
