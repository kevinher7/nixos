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
      default = "/home/${cfg.user}/nixos-config";
      description = "Directory provider sessions start in and the project picker opens at.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.t3code = {
      description = "T3 Code headless server";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Environment = "PATH=${
          lib.makeBinPath [
            pkgs.bashInteractive
            pkgs.coreutils
            pkgs.git
            pkgs.nodejs
            pkgs.openssh
          ]
        }:/run/current-system/sw/bin:/etc/profiles/per-user/${cfg.user}/bin:/home/${cfg.user}/.nix-profile/bin";
        WorkingDirectory = cfg.workingDirectory;
        ExecStart = "${lib.getExe cfg.package} serve --host ${cfg.host} --port ${toString cfg.port} --base-dir ${cfg.baseDir}";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.baseDir} 0700 ${cfg.user} users - -"
    ];
  };
}
