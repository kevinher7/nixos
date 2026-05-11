{
  config,
  lib,
  ...
}: let
  cfg = config.myHomelab;
in {
  options.myHomelab.nginxProxy = {
    enable = lib.mkEnableOption "Nginx reverse proxy with automatic HTTPS";
  };

  config = lib.mkIf cfg.nginxProxy.enable {
    # DuckDNS token for ACME DNS-01 challenge
    sops.secrets.duckdns_token = {
      owner = "acme";
      group = "acme";
      mode = "0400";
    };

    sops.templates."acme-duckdns.env" = {
      owner = "acme";
      group = "acme";
      mode = "0400";
      content = ''
        DUCKDNS_TOKEN=${config.sops.placeholder.duckdns_token}
      '';
    };

    # Let's Encrypt certificates via DNS-01 (no open ports required)
    security.acme = {
      acceptTerms = true;
      defaults.email = "kevinhernem@gmail.com";
      certs."uribogoat.duckdns.org" = {
        domain = "uribogoat.duckdns.org";
        extraDomainNames = [
          "vault.uribogoat.duckdns.org"
          "pihole.uribogoat.duckdns.org"
          "code.uribogoat.duckdns.org"
        ];
        dnsProvider = "duckdns";
        environmentFile = config.sops.templates."acme-duckdns.env".path;
        # Disable local propagation check — Let's Encrypt validates directly
        dnsPropagationCheck = false;
      };
    };

    # Nginx reverse proxy
    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      virtualHosts = {
        # Root domain is handled by the homepage dashboard module

        # Vaultwarden password manager
        "vault.uribogoat.duckdns.org" = {
          forceSSL = true;
          useACMEHost = "uribogoat.duckdns.org";
          locations."/" = {
            proxyPass = "http://127.0.0.1:1821";
            proxyWebsockets = true;
          };
        };

        # Pi-hole web interface
        "pihole.uribogoat.duckdns.org" = {
          forceSSL = true;
          useACMEHost = "uribogoat.duckdns.org";
          locations."/" = {
            proxyPass = "http://127.0.0.1:8080/";
          };
        };

        # Opencode web service
        "code.uribogoat.duckdns.org" = {
          forceSSL = true;
          useACMEHost = "uribogoat.duckdns.org";
          locations."/" = {
            proxyPass = "http://127.0.0.1:4096";
            proxyWebsockets = true;
          };
        };
      };
    };

    # Ensure nginx can read ACME certificates
    users.users.nginx.extraGroups = ["acme"];

    # Ensure ACME certificate is available before nginx starts
    systemd.services.nginx.after = ["acme-uribogoat.duckdns.org.service"];
    systemd.services.nginx.wants = ["acme-uribogoat.duckdns.org.service"];
  };
}
