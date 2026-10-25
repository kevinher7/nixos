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
      example = "example.com";
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

    harmoniaPublicKeys = {
      current = lib.mkOption {
        type = lib.types.str;
        description = ''
          Public key of the key Harmonia on the homelab server signs with.
          Every NixOS host trusts it for the binary cache.
        '';
        example = "cache.example.com-1:AAAA...=";
      };

      next = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          Public key of the next Harmonia signing key while a rotation is in
          progress. When set, every NixOS host trusts it too and the server
          also signs with the harmonia_signing_key_next secret.
        '';
        example = "cache.example.com-2:AAAA...=";
      };
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
