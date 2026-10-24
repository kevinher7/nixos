{
  config,
  username,
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
    ../../modules/t3code
  ];

  myVars = {
    domain = "beanhaven.net";
    acmeEmail = "kevinhernem@gmail.com";
    serverTailscaleIP = "100.87.121.69";

    lan = {
      gateway = "192.168.0.1";
      serverIP = "192.168.0.2";
      dhcp = {
        start = "192.168.0.100";
        end = "192.168.0.250";
      };
    };
  };

  users.users.${username}.linger = true;

  networking = {
    useDHCP = false;

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
    power.profile = "server";

    theming.wallpaper = ../../assets/wallpapers/girl-reading-book.png;

    networking = {
      enable = true;
      tailscale = {
        enable = true;
        openFirewall = true;
        ssh = true;
      };
      ssh.authorizedClients = ["kebee" "kebean" "uribo-btw"];
    };

    t3code.enable = true;
  };

  myHomelab = {
    nginxProxy.enable = true;
    homepage.enable = true;
    supervision = {
      enable = true;
      units = ["t3code"];
    };

    actual = {
      enable = true;
      domain = "budget.${config.myVars.domain}";
    };

    actualHttpApi = {
      enable = true;
      domain = "actual-api.${config.myVars.domain}";
      budgetSyncId = "d90c6528-ee2f-49e4-b5d1-5019b5136b1e";
    };

    mailBean.enable = true;

    llm.enable = true;

    ciRunner.enable = true;

    harmonia = {
      enable = true;
      domain = "cache.${config.myVars.domain}";
    };

    vaultwarden = {
      enable = true;
      domain = "https://vault.${config.myVars.domain}";
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
      openFirewallWeb = false;
    };
  };
}
