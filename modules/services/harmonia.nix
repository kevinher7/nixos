{
  config,
  lib,
  ...
}: let
  cfg = config.myHomelab;
in {
  options.myHomelab.harmonia = {
    enable = lib.mkEnableOption "Harmonia binary cache serving this host's Nix store";

    domain = lib.mkOption {
      type = lib.types.str;
      example = "cache.example.com";
      description = "Public domain for the binary cache (proxied via nginx)";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 5000;
      description = "Internal port for Harmonia";
    };
  };

  config = lib.mkIf cfg.harmonia.enable {
    # harmonia runs with DynamicUser and loads the key through systemd
    # credentials, so root ownership is enough.
    sops.secrets.harmonia_signing_key = {
      owner = "root";
      group = "root";
      mode = "0400";
    };

    services.harmonia.cache = {
      enable = true;
      signKeyPaths = [config.sops.secrets.harmonia_signing_key.path];
      settings.bind = "127.0.0.1:${toString cfg.harmonia.port}";
    };

    # This host resolves through Tailscale MagicDNS, which does not know the
    # homelab domain, and the shared substituter list includes this cache.
    networking.hosts."127.0.0.1" = [cfg.harmonia.domain];

    services.nginx.virtualHosts.${cfg.harmonia.domain} = {
      forceSSL = true;
      useACMEHost = config.myVars.domain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.harmonia.port}";
        extraConfig = ''
          proxy_read_timeout 300;
          proxy_buffering off;
        '';
      };
    };
  };
}
