{lib, ...}: {
  imports = [
    ./laptop.nix
    ./server.nix
  ];

  options.myModules.power.profile = lib.mkOption {
    type = lib.types.enum ["laptop" "server"];
    description = "Power management profile";
  };
}
