{ lib, pkgs, ... }:
{
  imports = [
    ./git.nix
    ./bash.nix
    ./ghostty.nix
    ./stylix.nix
    ./nixvim
    ./qtile
    ./programs
    ./rquickshare.nix
  ];

  programs.home-manager.enable = true;

  home = {
    # TODO: Modularize the username?
    username = "kevin";
    homeDirectory = lib.mkForce "/home/kevin";
    stateVersion = "25.05";

    packages = with pkgs; [
      curl
      unzip
      bitwarden-cli
      playerctl
    ];
  };
}
