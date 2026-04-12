{ lib, ... }:
{
  imports = [
    ./server.nix
    ./chromebook.nix
  ];

  options.myModules.power = {
    enable = lib.mkEnableOption "Power Management";

    profile = lib.mkOption {
      type = lib.types.enum [ "server" "chromebook" ];
      description = "Power management profile";
    };
  };
}
