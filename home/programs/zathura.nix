{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.myPrograms.zathura;
in {
  config = lib.mkIf cfg.enable {
    programs.zathura.enable = true;

    xdg.mimeApps = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      enable = true;
      defaultApplications."application/pdf" = "org.pwmt.zathura.desktop";
    };
  };
}
