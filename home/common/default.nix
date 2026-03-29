{ lib, pkgs, ... }:
{
  imports = [
    ./git.nix
    ./bash.nix
    ./stylix.nix
  ];

  programs.home-manager.enable = true;

  home = {
    username = "kevin";
    homeDirectory = lib.mkForce "/home/kevin";
    stateVersion = "25.05";

    packages = with pkgs; [
      curl
      bitwarden-cli
    ];
  };
}
