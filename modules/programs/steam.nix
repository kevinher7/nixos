{
  config,
  lib,
  ...
}: let
  cfg = config.myModules.programs.steam;
in {
  options.myModules.programs.steam.enable = lib.mkEnableOption "Steam game client";

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;
    programs.steam.enable = true;
  };
}
