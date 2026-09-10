{
  config,
  inputs,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.myModules.t3code;
  t3Packages = inputs.t3code.packages.${pkgs.stdenv.hostPlatform.system};

  # `t3 serve` only logs a warning when it cannot reach tailscaled, so without
  # this wait the unit comes up healthy while nothing answers on the tailnet.
  waitForTailscale = pkgs.writeShellScript "t3code-wait-for-tailscale" ''
    until ${lib.getExe pkgs.tailscale} status --json --peers=false |
      ${lib.getExe pkgs.jq} -e '.BackendState == "Running"' >/dev/null; do
      sleep 1
    done
  '';
in {
  options.myModules.t3code = {
    enable = lib.mkEnableOption "T3 Code headless server";

    package = lib.mkPackageOption t3Packages "t3-cli" {};

    user = lib.mkOption {
      type = lib.types.str;
      default = username;
      description = ''
        User the T3 Code server runs as. Never root, so that the T3 state and
        the provider credentials under the user's home stay user-owned.
      '';
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address the T3 Code server binds to.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3773;
      description = "Internal port for the T3 Code server.";
    };

    baseDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/t3code";
      description = "Directory holding the T3 Code database, sessions and pairing credentials.";
    };

    workingDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/home/${cfg.user}/projects";
      description = "Directory provider sessions start in and the project picker opens at.";
    };

    tailscaleServe = {
      enable = lib.mkEnableOption "publishing the T3 Code server over Tailscale Serve";

      httpsPort = lib.mkOption {
        type = lib.types.port;
        default = 443;
        description = "HTTPS port Tailscale Serve publishes the server on.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.tailscaleServe.enable -> config.myModules.networking.tailscale.operatorUser == cfg.user;
        message = "myModules.t3code.tailscaleServe needs myModules.networking.tailscale.operatorUser set to \"${cfg.user}\", otherwise tailscale serve is denied and the server stays unreachable.";
      }
    ];

    systemd.services.t3code = {
      description = "T3 Code headless server";
      after =
        ["network.target"]
        ++ lib.optionals cfg.tailscaleServe.enable ["tailscaled.service" "tailscaled-set.service"];
      wants = lib.optionals cfg.tailscaleServe.enable ["tailscaled.service"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Environment = "PATH=${
          lib.makeBinPath ([
              pkgs.bashInteractive
              pkgs.coreutils
              pkgs.git
              pkgs.nodejs
              pkgs.openssh
            ]
            ++ lib.optional cfg.tailscaleServe.enable pkgs.tailscale)
        }:/run/current-system/sw/bin:/etc/profiles/per-user/${cfg.user}/bin:/home/${cfg.user}/.nix-profile/bin";
        WorkingDirectory = cfg.workingDirectory;
        ExecStartPre = lib.optional cfg.tailscaleServe.enable waitForTailscale;
        ExecStart = lib.concatStringsSep " " ([
            (lib.getExe cfg.package)
            "serve"
            "--host ${cfg.host}"
            "--port ${toString cfg.port}"
            "--base-dir ${cfg.baseDir}"
          ]
          ++ lib.optionals cfg.tailscaleServe.enable [
            "--tailscale-serve"
            "--tailscale-serve-port ${toString cfg.tailscaleServe.httpsPort}"
          ]);
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.baseDir} 0700 ${cfg.user} users - -"
      "d ${cfg.workingDirectory} 0755 ${cfg.user} users - -"
    ];
  };
}
