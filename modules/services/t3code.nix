{
  config,
  inputs,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.myHomelab.t3code;
  t3Packages = inputs.t3code.packages.${pkgs.system};
in {
  options.myHomelab.t3code = {
    enable = lib.mkEnableOption "T3 Code headless server";

    package = lib.mkPackageOption t3Packages "t3-cli" {};

    domain = lib.mkOption {
      type = lib.types.str;
      default = "t3code.${config.myVars.domain}";
      description = "Public domain for the T3 Code server.";
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
      type = lib.types.path;
      default = /var/lib/t3code;
      description = "Base directory used by the T3 Code server.";
    };

    workingDirectory = lib.mkOption {
      type = lib.types.path;
      default = /home/${username}/nixos-config;
      description = "Working directory used as the default T3 Code project.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.t3code = {
      description = "T3 Code headless server";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        User = username;
        Environment = "PATH=${
          lib.makeBinPath [
            pkgs.bashInteractive
            pkgs.coreutils
            pkgs.git
            pkgs.nodejs
            pkgs.openssh
          ]
        }:/run/current-system/sw/bin:/etc/profiles/per-user/${username}/bin:/home/${username}/.nix-profile/bin";
        WorkingDirectory = cfg.workingDirectory;
        ExecStart = "${lib.getExe cfg.package} serve --host ${cfg.host} --port ${toString cfg.port} --base-dir ${toString cfg.baseDir}";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    systemd.tmpfiles.rules = [
      "d ${toString cfg.baseDir} 0700 ${username} users - -"
    ];

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = config.myVars.domain;
      locations."/" = {
        proxyPass = "http://${cfg.host}:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };
  };
}
