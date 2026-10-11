{config, ...}: {
  myPrograms.rofi.enable = true;

  xdg.configFile."qtile" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/home/desktops/qtile";
    recursive = true;
  };
}
