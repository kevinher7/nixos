{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.myPrograms.vicinae.enable {
    programs.vicinae = {
      enable = true;
      enableFirefoxIntegration = false;
      extensions = [
        (pkgs.fetchzip {
          name = "store.vicinae.bluetooth";
          url = "https://api.vicinae.com/v1/store/gelei/bluetooth/download";
          extension = "zip";
          stripRoot = false;
          hash = "sha256-tRVUysCT5kVTaoULZF/OJmI8v8OG7PNaZPTIUMJUZCo=";
        })
      ];
      systemd = {
        enable = true;
        target = config.wayland.systemd.target;
      };
      settings = {
        telemetry.system_info = false;
        input_server.enabled = false;
        providers.clipboard.preferences.monitoring = false;
        providers."store.vicinae.bluetooth".entrypoints.devices.alias = "bt";
        favorites = [];
        search_files_in_root = false;
        pop_to_root_on_close = true;
        close_on_focus_loss = true;
        # Let Sway manage focus so clicking another window dismisses the launcher.
        launcher_window.layer_shell.enabled = false;
      };
    };

    stylix.targets.vicinae.enable = false;

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
