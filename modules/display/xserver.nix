{ ... }:
{
  services.xserver = {
    enable = true;
    desktopManager.runXdgAutostartIfNone = true;
    xkb.layout = "jp";
    displayManager.sessionCommands = ''
      xwallpaper --zoom ~/walls/girl-reading-book.png
      xset r rate 400 35 &
    '';
  };
}
