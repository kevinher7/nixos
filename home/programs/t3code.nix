{
  lib,
  config,
  inputs,
  pkgs,
  ...
}: let
  cfg = config.myPrograms.t3code;
  t3Packages = inputs.t3code.packages.${pkgs.system};
in {
  config = lib.mkMerge [
    (lib.mkIf cfg.cli.enable {
      home.packages = [t3Packages.t3-cli];
    })

    (lib.mkIf cfg.desktop.enable {
      assertions = [
        {
          assertion = t3Packages ? desktop;
          message = "myPrograms.t3code.desktop is enabled but the t3code flake provides no desktop package for ${pkgs.system} (desktop is macOS-only).";
        }
      ];

      home.packages = lib.optionals (t3Packages ? desktop) [t3Packages.desktop];
    })
  ];
}
