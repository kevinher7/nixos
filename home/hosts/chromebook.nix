{pkgs, ...}: {
  imports = [../common ../desktops/qtile];

  myPrograms = {
    alacritty.enable = true;
    betterlockscreen.enable = true;
    qutebrowser.enable = true;
    rquickshare.enable = true;
    nixvim.enable = true;
  };

  home.packages = with pkgs; [
    playerctl
    pavucontrol
    pasystray
    pcmanfm
    papirus-icon-theme
  ];
}
