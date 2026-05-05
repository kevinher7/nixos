{
  config,
  lib,
  ...
}: let
  cfg = config.myHomelab;
in {
  options.myHomelab.pihole = {
    enable = lib.mkEnableOption "Pi-hole DNS sinkhole and ad blocker";

    webPort = lib.mkOption {
      type = lib.types.str;
      default = "8080";
      description = "Port for the Pi-hole web interface";
    };

    upstreamDNS = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["1.1.1.1" "1.0.0.1" "8.8.8.8"];
      description = "Upstream DNS servers";
    };

    localHosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "192.168.1.1   router.lan"
        "192.168.1.2   server.lan"
        "192.168.1.10  nas.lan"
      ];
      description = "Local DNS entries";
    };

    blocklists = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          url = lib.mkOption {type = lib.types.str;};
          type = lib.mkOption {
            type = lib.types.str;
            default = "block";
          };
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = true;
          };
          description = lib.mkOption {type = lib.types.str;};
        };
      });
      default = [
        {
          url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.txt";
          description = "Hagezi Pro Blocklist";
        }
        {
          url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
          description = "StevenBlack Unified Hosts";
        }
      ];
      description = "DNS blocklists to subscribe to";
    };

    openFirewallDNS = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open firewall for DNS (port 53)";
    };

    openFirewallWeb = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open firewall for web interface (port 8080/443)";
    };

    sessionTimeout = lib.mkOption {
      type = lib.types.int;
      default = 43200;
      description = "Web session timeout in seconds (default 12 hours)";
    };

    queryLogRetention = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      description = "Interval for query log cleanup";
    };
  };

  config = lib.mkIf cfg.pihole.enable {
    sops.templates."pihole.toml" = {
      owner = "pihole";
      group = "pihole";
      mode = "0400";
      content = let
        # Helper to format string arrays for TOML
        fmtStrings = arr: lib.concatMapStringsSep ", " (x: ''"${x}"'') arr;
      in ''
        [misc]
        readOnly = false
        dnsmasq_lines = ["address=/uribogoat.duckdns.org/192.168.0.33"]

        [dns]
        upstreams = [${fmtStrings cfg.pihole.upstreamDNS}]
        hosts = [${fmtStrings cfg.pihole.localHosts}]
        domainNeeded = true
        bogusPriv = true

        [webserver]
        port = "${cfg.pihole.webPort}"
        domain = "${config.services.pihole-web.hostName}"

        [webserver.paths]
        webroot = "${config.services.pihole-web.package}/share/"
        webhome = "/"

        [webserver.api]
        pwhash = '${lib.trim config.sops.placeholder.pihole_password}'

        [webserver.session]
        timeout = ${toString cfg.pihole.sessionTimeout}

        [ntp]
        ipv4.active = false
        ipv6.active = false
        sync.active = false
      '';
    };

    services = {
      pihole-ftl = {
        enable = true;

        inherit (cfg.pihole) openFirewallDNS;
        openFirewallWebserver = cfg.pihole.openFirewallWeb;

        lists = cfg.pihole.blocklists;

        # Settings are provided via sops template
        settings = {};

        queryLogDeleter = {
          enable = true;
          interval = cfg.pihole.queryLogRetention;
        };
      };

      pihole-web = {
        enable = true;
        ports = [cfg.pihole.webPort];
      };

      resolved.enable = false;

      dnsmasq.enable = false;
    };

    environment.etc."pihole/pihole.toml".source =
      lib.mkForce config.sops.templates."pihole.toml".path;

    systemd.services.pihole-ftl.restartTriggers = [
      config.sops.templates."pihole.toml".file
    ];
  };
}
