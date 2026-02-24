{ config, ... }:
{
  xdg.configFile."qtile" = {
    source = config.lib.file.mkOutOfStoreSymlink "/home/kevin/nixos-config/home/qtile";
    recursive = true;
  };
}
