{ config, ... }:
{
  xdg.configFile."qtile" = {
    source = config.lib.file.mkOutOfStoreSymlink "/home/kevin/nixos-config/config/qtile";
    recursive = true;
  };
}
