{ pkgs, ... }:
{
  imports = [
    ../common
    ../desktops/qtile
    ../programs/nixvim
    ../programs/betterlockscreen.nix
    ../programs/alacritty.nix
    ../programs/qutebrowser.nix
    ../programs/rquickshare.nix
  ];

  home.packages = with pkgs; [
    playerctl
    pavucontrol
    pasystray
    pcmanfm
    papirus-icon-theme
  ];
}
