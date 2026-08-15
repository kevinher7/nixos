{lib, ...}: {
  # Keep Stylix's palette and font declarations, but own the bar layout here.
  stylix.targets.waybar.addCss = false;

  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 32;

      modules-left = ["sway/workspaces"];
      modules-center = ["clock"];
      modules-right = ["network" "bluetooth"];

      "sway/workspaces" = {
        format = "{name}";
        disable-scroll-wraparound = true;
      };

      clock = {
        format = "{:%a %d %b  %H:%M}";
        tooltip-format = "<tt>{calendar}</tt>";
      };

      network = {
        interval = 5;
        format-wifi = "Wi-Fi  {essid} {signalStrength}%";
        format-ethernet = "Wired";
        format-disconnected = "Offline";
        format-disabled = "Wi-Fi off";
        tooltip-format-wifi = "{essid}\n{ipaddr}\nSignal: {signalStrength}%";
        tooltip-format-ethernet = "{ifname}\n{ipaddr}";
      };

      bluetooth = {
        format-off = "BT off";
        format-disabled = "BT off";
        format-on = "BT on";
        format-connected = "BT  {device_alias}";
        format-connected-battery = "BT  {device_alias} {device_battery_percentage}%";
        format-no-controller = "";
        tooltip-format = "{controller_alias}";
        tooltip-format-connected = "{controller_alias}\n\n{device_enumerate}";
        tooltip-format-enumerate-connected = "{device_alias}";
        tooltip-format-enumerate-connected-battery = "{device_alias}  {device_battery_percentage}%";
      };
    };

    style = lib.mkAfter (builtins.readFile ./waybar.css);
  };
}
