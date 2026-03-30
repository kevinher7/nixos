{ lib, pkgs, ... }:
{
  imports = [
    ./git.nix
    ./bash.nix
    ./stylix.nix
  ];

  programs.home-manager.enable = true;

  home = {
    # TODO: Modularize the username?
    username = "kevin";
    homeDirectory = lib.mkForce "/home/kevin";
    stateVersion = "25.05";

    packages = with pkgs; [
      btop
      tree
      gh
      curl
      pfetch
      bitwarden-cli
    ];
  };
}
