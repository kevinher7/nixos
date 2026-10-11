{config, ...}: {
  imports = [../rofi.nix];

  xdg.configFile."qtile" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/home/desktops/qtile";
    recursive = true;
  };
}
