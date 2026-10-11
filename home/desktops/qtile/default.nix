{config, ...}: {
  xdg.configFile."qtile" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/home/desktops/qtile";
    recursive = true;
  };
}
