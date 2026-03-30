_:
{
  services.xserver = {
    enable = true;
    desktopManager.runXdgAutostartIfNone = true;
    xkb.layout = "jp";
    displayManager.sessionCommands = ''
      xwallpaper --zoom ${../../assets/wallpapers/girl-reading-book.png}
      xset r rate 400 35 &
    '';
  };
}
