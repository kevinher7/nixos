{
  config,
  pkgs,
  ...
}: let
  wallpaper = config.myModules.theming.wallpaper;
in {
  services.xserver = {
    enable = true;
    desktopManager.runXdgAutostartIfNone = true;
    xkb.layout = "jp";
    displayManager.sessionCommands = ''
      xset r rate 400 35 &
      ${pkgs.xwallpaper}/bin/xwallpaper --zoom ${wallpaper}
    '';
  };
}
