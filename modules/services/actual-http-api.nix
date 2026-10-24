{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myHomelab;
  credentialsDir = "/run/credentials/actual-http-api.service";
  package = pkgs.buildNpmPackage {
    pname = "actual-http-api";
    inherit ((lib.importJSON "${inputs.actual-http-api}/package.json")) version;
    src = inputs.actual-http-api;
    npmDepsHash = "sha256-Y/SdLrj/qO7BQOgjK4Hyab35ZyZpgBVPhH2E3gNvFxY=";
    nodejs = pkgs.nodejs_22;
    nativeBuildInputs = [pkgs.python3 pkgs.makeWrapper];
    dontNpmBuild = true;
    postInstall = ''
      makeWrapper ${lib.getExe pkgs.nodejs_22} $out/bin/actual-http-api \
        --add-flags $out/lib/node_modules/actual-http-api/server.js
    '';
    meta.mainProgram = "actual-http-api";
  };
in {
  options.myHomelab.actualHttpApi = {
    enable = lib.mkEnableOption "actual-http-api, an HTTP API in front of Actual Budget";

    domain = lib.mkOption {
      type = lib.types.str;
      example = "actual-api.example.com";
      description = "Public domain for actual-http-api (proxied via nginx)";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 5007;
      description = "Internal port for actual-http-api (proxied via nginx)";
    };

    budgetSyncId = lib.mkOption {
      type = lib.types.str;
      description = "Sync ID of the only budget actual-http-api serves";
    };
  };

  config = lib.mkIf cfg.actualHttpApi.enable {
    myHomelab.supervision.units = ["actual-http-api"];

    sops.secrets = {
      actual_http_api_key = {};
      actual_server_password = {};
    };

    systemd.services.actual-http-api = {
      description = "HTTP API for Actual Budget";
      after = ["network-online.target" "actual.service"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      environment = {
        NODE_ENV = "production";
        PORT = toString cfg.actualHttpApi.port;
        ACTUAL_SERVER_URL = "http://127.0.0.1:${toString cfg.actual.port}/";
        ACTUAL_DATA_DIR = "/var/lib/actual-http-api";
        ALLOWED_BUDGET_SYNC_IDS = cfg.actualHttpApi.budgetSyncId;
        EXPERIMENTAL_OPERATIONS_ENABLED = "false";
        API_KEY_PATH = "${credentialsDir}/api_key";
        ACTUAL_SERVER_PASSWORD_PATH = "${credentialsDir}/actual_password";
        SWAGGER_HOST = cfg.actualHttpApi.domain;
      };

      serviceConfig = {
        ExecStart = lib.getExe package;
        DynamicUser = true;
        StateDirectory = "actual-http-api";
        LoadCredential = [
          "api_key:${config.sops.secrets.actual_http_api_key.path}"
          "actual_password:${config.sops.secrets.actual_server_password.path}"
        ];
        Restart = "on-failure";
      };
    };

    services.nginx.virtualHosts.${cfg.actualHttpApi.domain} = {
      forceSSL = true;
      useACMEHost = config.myVars.domain;
      locations."/".proxyPass = "http://127.0.0.1:${toString cfg.actualHttpApi.port}";
    };
  };
}
