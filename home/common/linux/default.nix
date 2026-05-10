{
  config,
  lib,
  ...
}:
lib.mkIf (config.myHome.os == "linux") {
  imports = [
    ./bash.nix
    ./rofi.nix
    ./stylix.nix
  ];
}
