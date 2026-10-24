{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myHomelab.supervision;
  failureLog = "/var/lib/homelab-supervision/failures.json";

  recordFailure = pkgs.writeShellApplication {
    name = "homelab-record-failure";
    runtimeInputs = [pkgs.jq pkgs.systemd];
    text = ''
      unit=$1
      log=$STATE_DIRECTORY/failures.json
      [ -f "$log" ] || echo '[]' >"$log"

      entry=$(jq -n \
        --arg unit "$unit" \
        --arg at "$(date -Is)" \
        --arg result "$(systemctl show -p Result --value "$unit")" \
        --arg restarts "$(systemctl show -p NRestarts --value "$unit")" \
        --arg exitStatus "$(systemctl show -p ExecMainStatus --value "$unit")" \
        --arg journal "$(journalctl -u "$unit" -n 50 --no-pager -o short-iso)" \
        '{unit: $unit, at: $at, result: $result, restarts: ($restarts | tonumber), exitStatus: ($exitStatus | tonumber), journal: $journal}')

      jq --argjson entry "$entry" '[$entry] + . | .[:50]' "$log" >"$log.tmp"
      mv "$log.tmp" "$log"
    '';
  };
in {
  options.myHomelab.supervision = {
    enable = lib.mkEnableOption "crash supervision and a failure log for homelab services";

    units = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Long-running systemd services that get the restart policy and failure recording.";
    };

    attempts = lib.mkOption {
      type = lib.types.int;
      default = 3;
      description = "Starts allowed within the interval before systemd gives up and marks the unit failed.";
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "5min";
      description = "Window the start attempts are counted in.";
    };

    failureLogPort = lib.mkOption {
      type = lib.types.port;
      default = 8084;
      description = "Localhost port nginx serves the failure log on, for the Homepage widget.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.homelab-supervision = {
      isSystemUser = true;
      group = "homelab-supervision";
      extraGroups = ["systemd-journal"];
    };
    users.groups.homelab-supervision = {};

    systemd.services =
      {
        "homelab-record-failure@" = {
          description = "Record the failure of %i";
          scriptArgs = "%i";
          script = lib.getExe recordFailure;
          serviceConfig = {
            Type = "oneshot";
            User = "homelab-supervision";
            Group = "homelab-supervision";
            StateDirectory = "homelab-supervision";
          };
        };
      }
      // lib.genAttrs cfg.units (_: {
        onFailure = ["homelab-record-failure@%n.service"];
        unitConfig = {
          StartLimitBurst = cfg.attempts;
          StartLimitIntervalSec = cfg.interval;
        };
        serviceConfig = {
          Restart = lib.mkDefault "on-failure";
          RestartSec = lib.mkDefault 10;
        };
      });

    services.nginx.virtualHosts.homelab-failures = {
      listen = [
        {
          addr = "127.0.0.1";
          port = cfg.failureLogPort;
        }
      ];
      locations."= /failures.json".alias = failureLog;
    };
  };
}
