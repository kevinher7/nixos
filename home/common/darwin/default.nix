{
  config,
  lib,
  ...
}:
lib.mkIf (config.myHome.os == "darwin") {
  imports = [
    ./zsh.nix
    ./starship.nix
  ];
}
