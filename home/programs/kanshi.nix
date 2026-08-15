{
  lib,
  config,
  ...
}: let
  cfg = config.myPrograms.kanshi;
in {
  config = lib.mkIf cfg.enable {
    services.kanshi.enable = true;
  };
}
