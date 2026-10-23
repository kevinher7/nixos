{
  lib,
  config,
  ...
}: let
  cfg = config.myPrograms.zathura;
in {
  config = lib.mkIf cfg.enable {
    programs.zathura.enable = true;

    xdg.mimeApps = {
      enable = true;
      defaultApplications."application/pdf" = "org.pwmt.zathura.desktop";
    };
  };
}
