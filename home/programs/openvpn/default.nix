{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.myPrograms.openvpn;

  mkCmd = name:
    pkgs.writeShellApplication {
      inherit name;
      text = builtins.replaceStrings ["@openvpn@"] [(lib.getExe pkgs.openvpn)] (builtins.readFile (./. + "/${name}.sh"));
    };
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.openvpn
      (mkCmd "ovpn")
      (mkCmd "ovpn-down")
      (mkCmd "ovpn-status")
    ];
  };
}
