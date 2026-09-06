{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myHomelab.mailBean;
  mailBeanPackages = inputs.mail-bean.packages.${pkgs.stdenv.hostPlatform.system};
  runLog = "/var/lib/mail-bean/runs.json";
in {
  options.myHomelab.mailBean = {
    enable = lib.mkEnableOption "mail-bean Gmail to Actual Budget importer";

    package = lib.mkPackageOption mailBeanPackages "default" {};

    schedule = lib.mkOption {
      type = lib.types.str;
      default = "hourly";
      description = "systemd OnCalendar expression for how often to import.";
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

    # Holds the full mail-bean env file: Gmail credentials, Actual password and sync id,
    # start date and the account/category/transfer maps. Server URL and data dir are set below.
    sops.secrets.mail_bean_env = {
      owner = "mail-bean";
      mode = "0400";
    };

    systemd.services.mail-bean = {
      description = "Import bank emails into Actual Budget";
      after = ["network-online.target" "actual.service"];
      wants = ["network-online.target"];

      environment = {
        MAIL_BEAN_ACTUAL_SERVER_URL = "http://127.0.0.1:${toString config.myHomelab.actual.port}";
        MAIL_BEAN_ACTUAL_DATA_DIR = "/var/lib/mail-bean";
        MAIL_BEAN_RUN_LOG = runLog;
      };

      serviceConfig = {
        Type = "oneshot";
        User = "mail-bean";
        Group = "mail-bean";
        StateDirectory = "mail-bean";
        EnvironmentFile = config.sops.secrets.mail_bean_env.path;
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
      locations."= /runs.json".alias = runLog;
    };
  };
}
