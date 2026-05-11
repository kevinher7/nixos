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
  };
}
