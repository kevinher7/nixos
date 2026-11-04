{
  config,
  lib,
  ...
}: let
  cfg = config.myHomelab;
  rotating = config.myVars.harmoniaPublicKeys.next != null;
  signingKeySecret = {
    owner = "root";
    group = "root";
    mode = "0400";
  };
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
    myHomelab.supervision.units = ["harmonia"];

    sops.secrets = {
      harmonia_signing_key = signingKeySecret;
      harmonia_signing_key_next = lib.mkIf rotating signingKeySecret;
    };

    services.harmonia.cache = {
      enable = true;
      signKeyPaths =
        [config.sops.secrets.harmonia_signing_key.path]
        ++ lib.optional rotating config.sops.secrets.harmonia_signing_key_next.path;
      settings.bind = "127.0.0.1:${toString cfg.harmonia.port}";
    };

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
