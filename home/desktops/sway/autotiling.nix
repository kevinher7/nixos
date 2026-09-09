{
  lib,
  pkgs,
  ...
}: {
  systemd.user.services.autotiling = {
    Unit = {
      Description = "Automatic split orientation for Sway";
      PartOf = ["sway-session.target"];
      ConditionEnvironment = "SWAYSOCK";
    };

    Service = {
      ExecStart = lib.getExe pkgs.autotiling;
      Restart = "on-failure";
    };

    Install.WantedBy = ["sway-session.target"];
  };
}
