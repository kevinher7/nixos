{
  lib,
  config,
  pkgs,
  ...
}: let
  terminal = lib.getExe config.programs.alacritty.package;
  launcher = "${lib.getExe config.programs.rofi.finalPackage} -show drun";

  # qtile used groups "1234"; nine is the same muscle memory with more room.
  workspaceBinds = lib.concatLists (lib.genList (i: let
      ws = toString (i + 1);
    in [
      "$mod, ${ws}, workspace, ${ws}"
      "$mod SHIFT, ${ws}, movetoworkspace, ${ws}"
    ])
    9);
in {
  wayland.windowManager.hyprland = {
    enable = true;

    # Pinned explicitly: home-manager flips this default to "lua" at
    # stateVersion 26.05, and the settings below are written as hyprlang.
    configType = "hyprlang";

    settings = {
      "$mod" = "SUPER";

      monitor = ",preferred,auto,1";

      input = {
        # Mirrors services.xserver.xkb.layout and the `xset r rate 400 35`
        # session command the qtile hosts use.
        kb_layout = "jp";
        repeat_delay = 400;
        repeat_rate = 35;

        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          tap-to-click = true;
        };
      };

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        layout = "dwindle";
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      misc = {
        # Stylix/hyprpaper own the background; Hyprland's built-in one would
        # only flash on startup.
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      bind =
        [
          # Launchers — same keys as the qtile config
          "$mod, Return, exec, ${terminal}"
          "$mod, d, exec, ${launcher}"
          "$mod, b, exec, qutebrowser"
          "$mod SHIFT, f, exec, pcmanfm"
          "$mod CTRL, l, exec, ${lib.getExe pkgs.hyprlock}"

          # Window management
          "$mod, q, killactive"
          "$mod, f, fullscreen"
          "$mod, t, togglefloating"
          "$mod, space, cyclenext"
          "$mod SHIFT, Return, togglesplit"
          "$mod CTRL, q, exit"

          # Focus (vim keys, as in qtile)
          "$mod, h, movefocus, l"
          "$mod, j, movefocus, d"
          "$mod, k, movefocus, u"
          "$mod, l, movefocus, r"

          # Move windows
          "$mod SHIFT, h, movewindow, l"
          "$mod SHIFT, j, movewindow, d"
          "$mod SHIFT, k, movewindow, u"
          "$mod SHIFT, l, movewindow, r"

          # Screenshots
          ''$mod SHIFT, s, exec, ${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp})" - | ${pkgs.wl-clipboard}/bin/wl-copy''
        ]
        ++ workspaceBinds;

      # Repeating binds — resize and the media/brightness keys
      binde = [
        "$mod CTRL, h, resizeactive, -40 0"
        "$mod CTRL, j, resizeactive, 0 40"
        "$mod CTRL, k, resizeactive, 0 -40"
        "$mod CTRL, l, resizeactive, 40 0"
      ];

      bindel = [
        ", XF86AudioRaiseVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        # `light` is X11-only; brightnessctl is the Wayland equivalent.
        ", XF86MonBrightnessUp, exec, ${lib.getExe pkgs.brightnessctl} set 10%+"
        ", XF86MonBrightnessDown, exec, ${lib.getExe pkgs.brightnessctl} set 10%-"
      ];

      bindl = [
        ", XF86AudioMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];

      # Super + left/right drag, matching the qtile mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

  services.hyprpaper.enable = true;

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || ${lib.getExe pkgs.hyprlock}";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      # Suspend/hibernate is left to logind (see modules/power/dell.nix), so
      # these listeners only lock and blank the panel.
      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 330;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general.hide_cursor = true;

      background = [
        {
          blur_passes = 2;
          blur_size = 8;
        }
      ];

      input-field = [
        {
          size = "300, 50";
          position = "0, -80";
          halign = "center";
          valign = "center";
          fade_on_empty = false;
          placeholder_text = "";
        }
      ];
    };
  };

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
  };
}
