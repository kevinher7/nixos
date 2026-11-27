{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.myModules.virtualisation;
in {
  imports = [inputs.microvm.nixosModules.host];

  options.myModules.virtualisation = {
    enable = lib.mkEnableOption "the personal coding VM";
    autostart = lib.mkOption {
      type = lib.types.bool;
      description = "Start agent-dev at boot after host capacity has been verified.";
    };
    allowedDomains = lib.mkOption {
      type = lib.types.nonEmptyListOf lib.types.str;
      description = "Exact destinations reachable through the guest HTTP proxy.";
    };
    deniedNetworks = lib.mkOption {
      type = lib.types.nonEmptyListOf lib.types.str;
      description = "Destination CIDRs denied by both Squid and its systemd service.";
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
        acl denied_destinations dst ${lib.concatStringsSep " " cfg.deniedNetworks}
        acl web_ports port 80 443
        http_access deny !agent_guest
        http_access deny !web_ports
        http_access deny denied_destinations
        http_access allow agent_guest agent_destinations
        http_access deny all
        cache deny all
      '';
    };
    systemd.services.squid.serviceConfig.IPAddressDeny = cfg.deniedNetworks;

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
