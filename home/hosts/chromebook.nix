{ pkgs, ... }:
{
  imports = [
    ../common
    ../desktops/qtile
    ../programs/nixvim
    ../programs/betterlockscreen.nix
    ../programs/ghostty.nix
    ../programs/qutebrowser.nix
    ../programs/rquickshare.nix
  ];

  home.packages = with pkgs; [
    playerctl
  ];
}
