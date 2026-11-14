{
  config,
  username,
  ...
}: let
  vaultDomain = "vault.${config.myVars.domain}";
  budgetDomain = "budget.${config.myVars.domain}";
  actualApiDomain = "actual-api.${config.myVars.domain}";
  cacheDomain = "cache.${config.myVars.domain}";
in {
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
    ../../modules/virtualisation
    ../../modules/agent-user
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
        ssh = false;
      };
      ssh.authorizedClients = ["kebee" "kebean"];
    };

    virtualisation = {
      enable = true;
      autostart = false;
      allowedDomains = [
        "github.com"
        "api.github.com"
        "raw.githubusercontent.com"
        "codeload.github.com"
        "objects.githubusercontent.com"
        "release-assets.githubusercontent.com"
        "registry.npmjs.org"
        "pypi.org"
        "files.pythonhosted.org"
        "cache.nixos.org"
        "channels.nixos.org"
        "releases.nixos.org"
        "cache.numtide.com"
        "kevinher7-nixos.cachix.org"
        "api.openai.com"
        "auth.openai.com"
        "chatgpt.com"
        "api.anthropic.com"
        "claude.ai"
        "console.anthropic.com"
        "platform.claude.com"
        "openrouter.ai"
      ];
      deniedNetworks = [
        "0.0.0.0/8"
        "10.0.0.0/8"
        "100.64.0.0/10"
        "127.0.0.0/8"
        "169.254.0.0/16"
        "172.16.0.0/12"
        "192.168.0.0/16"
        "224.0.0.0/4"
        "240.0.0.0/4"
        "::/0"
      ];
    };

    agentUser.enable = true;

    t3code = {
      enable = true;
      user = config.myModules.agentUser.name;
    };
  };

  microvm.vms.agent-dev.config.microvm = {
    hypervisor = "qemu";
    vcpu = 2;
    mem = 3072;
    volumes = [
      {
        image = "root.img";
        mountPoint = "/";
        size = 40 * 1024;
      }
    ];
  };

  systemd.services."microvm@agent-dev".serviceConfig.CPUWeight = 20;

  myHomelab = {
    nginxProxy.enable = true;
    webAccess = {
      enable = true;
      privateGroups = ["private"];
      sharedHosts.${vaultDomain}.groups = ["vaultGuests"];
    };
    homepage.enable = true;
    supervision = {
      enable = true;
      units = ["t3code"];
    };

    actual = {
      enable = true;
      domain = budgetDomain;
    };

    actualHttpApi = {
      enable = true;
      domain = actualApiDomain;
      budgetSyncId = "d90c6528-ee2f-49e4-b5d1-5019b5136b1e";
    };

    mailBean.enable = true;

    llm.enable = true;

    ciRunner.enable = true;

    harmonia = {
      enable = true;
      domain = cacheDomain;
    };

    vaultwarden = {
      enable = true;
      domain = "https://${vaultDomain}";
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
