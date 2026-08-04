{lib, ...}: {
  imports = [
    ./server.nix
    ./chromebook.nix
    ./dell.nix
  ];

  options.myModules.power = {
    enable = lib.mkEnableOption "Power Management";

    profile = lib.mkOption {
      type = lib.types.enum ["server" "chromebook" "dell"];
      description = "Power management profile";
    };
  };
}
