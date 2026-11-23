{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myHomelab.beanBudget;
  beanBudgetPackages = inputs.bean-budget.packages.${pkgs.stdenv.hostPlatform.system};
  stateDir = "/var/lib/bean-budget";
  database = "${stateDir}/bean-budget.sqlite";
  upstream = "http://127.0.0.1:${toString cfg.port}";

  backup = pkgs.writeShellApplication {
    name = "bean-budget-backup-rotate";
    runtimeInputs = [pkgs.coreutils pkgs.findutils];
    text = ''
      dir=${stateDir}/backups
      mkdir -p "$dir"
      ${lib.getExe' cfg.package "bean-budget-backup"} export ${database} "$dir/$(date +%Y%m%dT%H%M%S)"
      find "$dir" -mindepth 1 -maxdepth 1 -type d | sort | head -n -${toString cfg.backup.keep} | xargs -r rm -rf
    '';
  };
in {
  options.myHomelab.beanBudget = {
    enable = lib.mkEnableOption "Bean Budget ledger server";

    package = lib.mkPackageOption beanBudgetPackages "server" {};

    domain = lib.mkOption {
      type = lib.types.str;
      example = "bean.example.com";
      description = "Public domain for the Bean Budget server (proxied via nginx)";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 5008;
      description = "Internal port for the Bean Budget server (proxied via nginx)";
    };

    mail.enable = lib.mkEnableOption "Gmail debit notice ingestion. Needs the Gmail settings in the env secret";

    backup = {
      schedule = lib.mkOption {
        type = lib.types.str;
        default = "daily";
        description = "systemd OnCalendar expression for verified SQLite backups.";
      };

      keep = lib.mkOption {
        type = lib.types.ints.positive;
        default = 14;
        description = "Number of backups kept in ${stateDir}/backups.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    myHomelab.supervision.units = ["bean-budget"];

    users.users.bean-budget = {
      isSystemUser = true;
      group = "bean-budget";
    };
    users.groups.bean-budget = {};

    sops.secrets.bean_budget_env = {
      sopsFile = ../../secrets/services/bean-budget.yaml;
      owner = "bean-budget";
      mode = "0400";
      restartUnits = ["bean-budget.service"];
    };

    systemd.services.bean-budget = {
      description = "Bean Budget ledger server";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      environment = {
        BEAN_HOST = "127.0.0.1";
        BEAN_PORT = toString cfg.port;
        BEAN_DATABASE = database;
        BEAN_MAIL_ENABLED = lib.boolToString cfg.mail.enable;
      };

      serviceConfig = {
        User = "bean-budget";
        Group = "bean-budget";
        StateDirectory = "bean-budget";
        StateDirectoryMode = "0700";
        EnvironmentFile = config.sops.secrets.bean_budget_env.path;
        ExecStart = lib.getExe cfg.package;
      };
    };

    systemd.services.bean-budget-backup = {
      description = "Export a verified Bean Budget backup";
      after = ["bean-budget.service"];
      onFailure = lib.optional config.myHomelab.supervision.enable "homelab-record-failure@%n.service";

      serviceConfig = {
        Type = "oneshot";
        User = "bean-budget";
        Group = "bean-budget";
        StateDirectory = "bean-budget";
        StateDirectoryMode = "0700";
        ExecStart = lib.getExe backup;
      };
    };

    systemd.timers.bean-budget-backup = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = cfg.backup.schedule;
        Persistent = true;
        RandomizedDelaySec = "15m";
      };
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = config.myVars.domain;
      locations = {
        "/".proxyPass = upstream;
        "= /notifications" = {
          proxyPass = upstream;
          proxyWebsockets = true;
          extraConfig = "access_log off;";
        };
      };
    };
  };
}
