_:
{
  services.xserver = {
    enable = true;
    desktopManager.runXdgAutostartIfNone = true;
    xkb.layout = "jp";
    displayManager.sessionCommands = ''
      xset r rate 400 35 &
    '';
  };
}
