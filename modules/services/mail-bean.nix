{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myHomelab.mailBean;
  mailBeanPackages = inputs.mail-bean.packages.${pkgs.stdenv.hostPlatform.system};
in {
  options.myHomelab.mailBean = {
    enable = lib.mkEnableOption "mail-bean Gmail to Actual Budget importer";

    package = lib.mkPackageOption mailBeanPackages "default" {};

    schedule = lib.mkOption {
      type = lib.types.str;
      default = "hourly";
      description = "systemd OnCalendar expression for how often to import.";
    };

    runLog = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/mail-bean/runs.json";
      description = "JSON file mail-bean keeps its last run summaries in. Must be writable by the mail-bean user.";
    };

    runLogPort = lib.mkOption {
      type = lib.types.port;
      default = 8083;
      description = "Localhost port nginx serves the run log on, for the Homepage widget.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.mail-bean = {
      isSystemUser = true;
      group = "mail-bean";
    };
    users.groups.mail-bean = {};

    sops = {
      secrets = {
        mail_bean_settings_env = {};
        gmail_client_secret = {};
        gmail_refresh_token = {};
        actual_server_password = {};
      };

      templates."mail-bean.env" = {
        owner = "mail-bean";
        mode = "0400";
        content = ''
          ${config.sops.placeholder.mail_bean_settings_env}
          MAIL_BEAN_GOOGLE_CLIENT_SECRET=${config.sops.placeholder.gmail_client_secret}
          MAIL_BEAN_GOOGLE_REFRESH_TOKEN=${config.sops.placeholder.gmail_refresh_token}
          MAIL_BEAN_ACTUAL_PASSWORD=${config.sops.placeholder.actual_server_password}
        '';
      };
    };

    systemd.services.mail-bean = {
      description = "Import bank emails into Actual Budget";
      after = ["network-online.target" "actual.service"];
      wants = ["network-online.target"];

      environment = {
        MAIL_BEAN_ACTUAL_SERVER_URL = "http://127.0.0.1:${toString config.myHomelab.actual.port}";
        MAIL_BEAN_ACTUAL_DATA_DIR = "/var/lib/mail-bean";
        MAIL_BEAN_RUN_LOG = cfg.runLog;
      };

      serviceConfig = {
        Type = "oneshot";
        TimeoutStartSec = "5min";
        User = "mail-bean";
        Group = "mail-bean";
        StateDirectory = "mail-bean";
        EnvironmentFile = config.sops.templates."mail-bean.env".path;
        ExecStart = lib.getExe cfg.package;
      };
    };

    systemd.timers.mail-bean = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = cfg.schedule;
        Persistent = true;
        RandomizedDelaySec = "5m";
      };
    };

    services.nginx.virtualHosts.mail-bean-runs = {
      listen = [
        {
          addr = "127.0.0.1";
          port = cfg.runLogPort;
        }
      ];
      locations."= /runs.json".alias = cfg.runLog;
    };
  };
}
