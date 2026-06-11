{
  config,
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

  myVars = {
    domain = "uribogoat.duckdns.org";
    acmeEmail = "kevinhernem@gmail.com";
    serverTailscaleIP = "100.87.121.69";

    gitUser = {
      name = "Kevin Hernandez";
      email = "kevinhernem@gmail.com";
    };

    opencodePort = 4096;

    lan = {
      gateway = "192.168.0.1";
      serverIP = "192.168.0.2";
      dhcp = {
        start = "192.168.0.100";
        end = "192.168.0.250";
      };
    };
  };

  time.timeZone = "Asia/Tokyo";

  networking = {
    useDHCP = lib.mkForce false;

    # Tell NetworkManager not to touch enp2s0; we manage it declaratively
    networkmanager.unmanaged = ["enp2s0"];

    interfaces.enp2s0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = config.myVars.lan.serverIP;
          prefixLength = 24;
        }
      ];
    };

    defaultGateway = {
      address = config.myVars.lan.gateway;
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
      domain = "https://vault.${config.myVars.domain}";
    };

    t3code = {
      enable = true;
      domain = "t3code.${config.myVars.domain}";
    };

    pihole = {
      enable = true;
      localDomainIP = config.myVars.serverTailscaleIP;

      upstreamDNS = ["1.1.1.1" "1.0.0.1" "8.8.8.8"];

      dhcp = {
        enable = true;
        active = true;

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
