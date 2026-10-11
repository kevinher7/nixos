{
  lib,
  config,
  pkgs,
  hostname,
  ...
}: let
  cfg = config.myPrograms.rquickshare;
in {
  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        rquickshare
        libayatana-appindicator
      ];

      # Does not use ~/.config
      file.".local/share/dev.mandre.rquickshare/.settings.json".text = builtins.toJSON {
        device_name = hostname;
        port = 9300;
        server_port = 9300;
        download_directory = "${config.home.homeDirectory}/downloads";
        light_mode = false;
        show_notifications = true;
        auto_start = false;
        autostart = false;
        startminimized = false;
        realclose = false;
        visibility = 2;
      };
    };

    services.dunst.enable = true;
  };
}
