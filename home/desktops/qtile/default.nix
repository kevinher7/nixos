{
  pkgs,
  config,
  ...
}: {
  programs.gdk-pixbuf.modulePackages = [pkgs.librsvg];

  xdg.configFile."qtile" = {
    source = config.lib.file.mkOutOfStoreSymlink "/home/kevin/nixos-config/home/desktops/qtile";
    recursive = true;
  };
}
