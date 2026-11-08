{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.myPrograms.dbeaver.enable {
    home.packages = [pkgs.dbeaver-bin];
  };
}
