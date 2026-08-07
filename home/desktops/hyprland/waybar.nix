{
  lib,
  pkgs,
  ...
}: {
  # stylix keeps emitting the `@define-color base00 … base0F` block and the
  # font rules; addCss = false drops the rest of its stylesheet so waybar.css
  # is the only source of layout and colour rules.
  stylix.targets.waybar.addCss = false;

  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 32;

      modules-left = ["hyprland/workspaces"];
      modules-center = ["clock"];
      modules-right = ["pulseaudio" "network" "battery" "tray"];

      "hyprland/workspaces" = {
        format = "{name}";
        on-click = "activate";
      };

      clock = {
        format = "{:%a %d %b  %H:%M}";
        tooltip-format = "<tt>{calendar}</tt>";
      };

      pulseaudio = {
        format = "  {volume}%";
        format-muted = "  muted";
        on-click = "${lib.getExe pkgs.pavucontrol}";
      };

      network = {
        format-wifi = "  {essid}";
        format-ethernet = "  wired";
        format-disconnected = "  offline";
      };

      battery = {
        format = "{icon}  {capacity}%";
        format-charging = "  {capacity}%";
        format-icons = ["" "" "" "" ""];
        states = {
          warning = 30;
          critical = 15;
        };
      };

      tray.spacing = 8;
    };

    # `style` is types.lines, so this concatenates with stylix's definition
    # rather than conflicting. mkAfter keeps ours last: the @define-color block
    # has to be declared before @base0D and friends are referenced.
    style = lib.mkAfter (builtins.readFile ./waybar.css);
  };
}
