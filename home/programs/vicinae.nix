{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.myPrograms.vicinae.enable {
    programs.vicinae = {
      enable = true;
      enableFirefoxIntegration = false;
      systemd = {
        enable = true;
        target = config.wayland.systemd.target;
      };
      settings = {
        telemetry.system_info = false;
        input_server.enabled = false;
        providers.clipboard.preferences.monitoring = false;
        favorites = [];
        search_files_in_root = false;
        pop_to_root_on_close = true;
      };
    };

    stylix.targets.vicinae.enable = true;

    # The packaged entry replaces the server, bypassing the systemd service.
    xdg.desktopEntries.vicinae = {
      name = "Vicinae";
      genericName = "Launcher";
      exec = "${lib.getExe config.programs.vicinae.package} toggle";
      icon = "vicinae";
      terminal = false;
      categories = ["Utility" "Accessibility"];
    };
  };
}
