{ config, lib, ... }:
{
  programs.opencode = {
    enable = true;
    # tui.themes = "nord";
  };

  systemd.user.services.opencode-web = {
    Unit = {
      Description = "OpenCode Web Service";
      After = [ "network.target" ];
    };

    Service = {
      ExecStart = "${lib.getExe config.programs.opencode.package} serve --hostname 0.0.0.0 --port 4096";
      Restart = "always";
      RestartSec = 5;
      # TODO: add EnvironmentFile with sops-nix password
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
