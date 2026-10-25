{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.myPrograms.sops;
in {
  config = lib.mkIf cfg.enable {
    home = {
      packages = [pkgs.sops pkgs.age];

      sessionVariables = lib.mkIf cfg.adminKey.enable {
        SOPS_AGE_KEY_CMD = "${lib.getExe pkgs.age} -d ${config.xdg.configHome}/sops/age/admin.age";
      };
    };
  };
}
