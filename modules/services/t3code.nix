{
  config,
  lib,
  ...
}: let
  cfg = config.myHomelab.t3code;
  server = config.myModules.t3code;
in {
  options.myHomelab.t3code = {
    enable = lib.mkEnableOption "public HTTPS endpoint for the T3 Code server";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "t3code.${config.myVars.domain}";
      description = "Public domain for the T3 Code server.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = server.enable;
        message = "myHomelab.t3code proxies the T3 Code server through nginx, but myModules.t3code is disabled.";
      }
    ];

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = config.myVars.domain;
      locations."/" = {
        proxyPass = "http://${server.host}:${toString server.port}";
        proxyWebsockets = true;
      };
    };
  };
}
