{
  config,
  pkgs,
  ...
}: {
  xdg.configFile."qtile" = {
    source = config.lib.file.mkOutOfStoreSymlink "/home/kevin/nixos-config/home/desktops/qtile";
    recursive = true;
  };

  # Wallpaper daemon for qtile's Wayland backend (unused on X11, where
  # xwallpaper is available from the system config instead).
  home.packages = [pkgs.swaybg];
}
