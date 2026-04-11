{ lib, pkgs, username, ... }:
{
  imports = [
    ./git.nix
    ./bash.nix
    ./rofi.nix
    ./stylix.nix
  ];

  programs.home-manager.enable = true;

  home = {
    username = username;
    homeDirectory = lib.mkForce "/home/${username}";
    stateVersion = "25.05";

    packages = with pkgs; [
      btop
      tree
      gh
      curl
      pfetch
    ];
  };
}
