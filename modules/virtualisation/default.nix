{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.myModules.virtualisation;
  privateNetworks = [
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
in {
  imports = [inputs.microvm.nixosModules.host];

  options.myModules.virtualisation = {
    enable = lib.mkEnableOption "the personal coding VM";
    autostart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Start agent-dev at boot after host capacity has been verified.";
    };
    allowedDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
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
      description = "Exact destinations reachable through the guest HTTP proxy.";
    };
  };

  config = lib.mkIf cfg.enable {
    microvm.vms.agent-dev = {
      inherit (cfg) autostart;
      specialArgs = {
        inherit inputs;
        username = "agent";
      };
      config.imports = [../../hosts/virtual/agent-dev.nix];
    };

    systemd.services."microvm@agent-dev" = {
      requires = ["nftables.service"];
      after = ["nftables.service" "systemd-networkd.service"];
      serviceConfig.CPUWeight = 20;
    };

    networking.networkmanager.unmanaged = ["vm-agent-dev"];
    systemd.network = {
      enable = true;
      networks."30-agent-dev" = {
        matchConfig.Name = "vm-agent-dev";
        address = ["172.31.255.1/30"];
        networkConfig = {
          DHCP = "no";
          LinkLocalAddressing = "no";
          IPv6AcceptRA = false;
        };
        linkConfig.RequiredForOnline = "no";
      };
    };

    networking = {
      firewall.interfaces."vm-agent-dev".allowedTCPPorts = [3129];
      nftables = {
        enable = true;
        tables.agent-dev = {
          family = "inet";
          content = ''
            chain input {
              type filter hook input priority -10; policy accept;
              iifname "vm-agent-dev" ct state established ct direction reply accept
              iifname "vm-agent-dev" ip saddr 172.31.255.2 ip daddr 172.31.255.1 tcp dport 3129 accept
              iifname "vm-agent-dev" drop
            }
            chain forward {
              type filter hook forward priority -10; policy accept;
              iifname "vm-agent-dev" drop
              oifname "vm-agent-dev" drop
            }
          '';
        };
      };
    };

    services.squid = {
      enable = true;
      proxyAddress = "0.0.0.0";
      proxyPort = 3129;
      extraConfig = ''
        acl agent_guest src 172.31.255.2/32
        acl agent_destinations dstdomain -n ${lib.concatStringsSep " " cfg.allowedDomains}
        acl private_destinations dst ${lib.concatStringsSep " " privateNetworks}
        acl web_ports port 80 443
        http_access deny !agent_guest
        http_access deny !web_ports
        http_access deny private_destinations
        http_access allow agent_guest agent_destinations
        http_access deny all
        cache deny all
      '';
    };
    systemd.services.squid.serviceConfig.IPAddressDeny = privateNetworks;

    security.acme.certs.${config.myVars.domain}.extraDomainNames = ["agent-dev.${config.myVars.domain}"];
    services.nginx.virtualHosts."agent-dev.${config.myVars.domain}" = {
      forceSSL = true;
      useACMEHost = config.myVars.domain;
      locations."/" = {
        proxyPass = "http://172.31.255.2:3773";
        proxyWebsockets = true;
        extraConfig = "proxy_read_timeout 3600s;";
      };
    };
  };
}
