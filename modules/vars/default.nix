{lib, ...}: {
  options.myVars = {
    domain = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Primary public domain (apex) used by homelab services for reverse-proxy
        virtual hosts, ACME certificates and split-horizon DNS. Subdomains are
        composed at the point of use, e.g. "vault.''${config.myVars.domain}".
      '';
      example = "uribogoat.duckdns.org";
    };

    acmeEmail = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Email address registered with the ACME provider (Let's Encrypt) for
        certificate issuance and expiry notifications.
      '';
      example = "you@example.com";
    };

    gitUser = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Name used for the git committer/author identity.";
        example = "Jane Doe";
      };

      email = lib.mkOption {
        type = lib.types.str;
        description = "Email used for the git committer/author identity.";
        example = "you@example.com";
      };
    };

    serverTailscaleIP = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Tailnet IP address of the homelab server. Used by the server itself for
        split-horizon DNS (resolving the public domain to the tailnet address)
        and by other hosts that need to reach the server over Tailscale.
      '';
      example = "100.64.0.1";
    };

    opencodePort = lib.mkOption {
      type = lib.types.port;
      description = ''
        Port the opencode web service listens on. Used by the server's
        reverse proxy and dashboard and by the opencode shell aliases on
        every host.
      '';
      example = 4096;
    };

    lan = {
      gateway = lib.mkOption {
        type = lib.types.str;
        description = ''
          LAN IP address of the router. Used as the default gateway, advertised
          to DHCP clients and resolved as router.lan by Pi-hole.
        '';
        example = "192.168.0.1";
      };

      serverIP = lib.mkOption {
        type = lib.types.str;
        description = ''
          Static LAN IP address of the homelab server, resolved as server.lan
          by Pi-hole.
        '';
        example = "192.168.0.2";
      };

      dhcp = {
        start = lib.mkOption {
          type = lib.types.str;
          description = "Start of the DHCP range handed out by Pi-hole.";
          example = "192.168.0.100";
        };

        end = lib.mkOption {
          type = lib.types.str;
          description = "End of the DHCP range handed out by Pi-hole.";
          example = "192.168.0.250";
        };
      };
    };
  };
}
