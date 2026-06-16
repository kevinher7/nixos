{
  config,
  lib,
  ...
}: let
  cfg = config.myHomelab;
in {
  options.myHomelab.actual = {
    enable = lib.mkEnableOption "Actual Budget self-hosted budgeting server";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "budget.${config.myVars.domain}";
      example = "budget.example.com";
      description = "Public domain for Actual Budget (proxied via nginx)";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 5006;
      description = "Internal port for Actual Budget (proxy to this via nginx)";
    };
  };

  config = lib.mkIf cfg.actual.enable {
    services.actual = {
      enable = true;
      settings = {
        hostname = "127.0.0.1";
        port = cfg.actual.port;
      };
    };

    services.nginx.virtualHosts.${cfg.actual.domain} = {
      forceSSL = true;
      useACMEHost = config.myVars.domain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.actual.port}";
        proxyWebsockets = true;
      };
    };
  };
}
