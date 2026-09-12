{pkgs, ...}: {
  imports = [../common ../programs ../desktops/qtile];

  myPrograms = {
    agents.codex.enable = true;
    alacritty.enable = true;
    betterlockscreen.enable = true;
    qutebrowser.enable = true;
    rquickshare.enable = true;
    nixvim.enable = true;
    t3code.cli.enable = true;
  };

  home.packages = with pkgs; [
    playerctl
    pavucontrol
    pasystray
    pcmanfm
    papirus-icon-theme
  ];
}
