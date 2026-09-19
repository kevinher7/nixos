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
      systemd = {
        enable = true;
        target = config.wayland.systemd.target;
      };
      settings = {
        telemetry.system_info = false;
        input_server.enabled = false;
        providers.clipboard.preferences.monitoring = false;
        providers.scripts.entrypoints."toggle-bluetooth.sh".alias = "bt";
        favorites = [];
        search_files_in_root = false;
        pop_to_root_on_close = true;
      };
    };

    stylix.targets.vicinae.enable = true;

    xdg.dataFile."vicinae/scripts/toggle-bluetooth.sh".source = lib.getExe (pkgs.writeShellApplication {
      name = "toggle-bluetooth";
      runtimeInputs = [pkgs.bluez pkgs.coreutils];
      text = ''
        # @vicinae.schemaVersion 1
        # @vicinae.title Toggle Bluetooth
        # @vicinae.mode compact

        export LC_ALL=C
        # Vicinae stops compact commands after 10s; keep the total timeout below it.
        if ! controller=$(timeout 2s bluetoothctl show 2>&1); then
          printf 'Cannot read Bluetooth adapter: %s\n' "$controller"
          exit 1
        fi

        if [[ $controller =~ Powered:[[:space:]]+yes ]]; then
          power=off
          expected=no
        elif [[ $controller =~ Powered:[[:space:]]+no ]]; then
          power=on
          expected=yes
        else
          echo "No Bluetooth adapter available"
          exit 1
        fi

        if ! result=$(timeout 4s bluetoothctl power "$power" 2>&1); then
          printf 'Cannot turn Bluetooth %s: %s\n' "$power" "$result"
          exit 1
        fi

        if ! controller=$(timeout 2s bluetoothctl show 2>&1) ||
           [[ ! $controller =~ Powered:[[:space:]]+$expected ]]; then
          printf 'Bluetooth did not turn %s: %s\n' "$power" "$result"
          exit 1
        fi

        printf 'Bluetooth turned %s\n' "$power"
      '';
    });

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
