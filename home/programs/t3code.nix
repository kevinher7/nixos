{
  lib,
  config,
  inputs,
  pkgs,
  ...
}: let
  cfg = config.myPrograms.t3code;
in {
  config = lib.mkIf cfg.enable {
    home.packages =
      [inputs.t3code.packages.${pkgs.system}.t3-cli]
      ++ lib.optionals (inputs.t3code.packages.${pkgs.system} ? desktop) [
        inputs.t3code.packages.${pkgs.system}.desktop
      ];
  };
}
