{
  config,
  lib,
  pkgs,
  ...
}: let
  mod = "Mod4";
  terminal = lib.getExe config.programs.alacritty.package;
  launcher = "${lib.getExe config.programs.rofi.finalPackage} -show drun";
  lock = "${lib.getExe pkgs.swaylock} -f";
  wallpaper = ../../../assets/wallpapers/girl-reading-book.png;

  workspaceBindings = builtins.listToAttrs (
    lib.concatMap (
      number: let
        workspace = toString number;
      in [
        {
          name = "${mod}+${workspace}";
          value = "workspace number ${workspace}";
        }
        {
          name = "${mod}+Shift+${workspace}";
          value = "move container to workspace number ${workspace}";
        }
      ]
    ) (lib.range 1 9)
  );
in {
  # Tie Kanshi, swayidle, and other Wayland services to the Sway session.
  wayland.systemd.target = "sway-session.target";

  wayland.windowManager.sway = {
    enable = true;

    # The NixOS module owns the compositor package and display-manager entry.
    package = null;

    config = {
      modifier = mod;
      inherit terminal;
      menu = launcher;

      input = {
        "type:keyboard" = {
          xkb_layout = "jp";
          repeat_delay = "400";
          repeat_rate = "35";
        };

        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
          dwt = "enabled";
        };
      };

      gaps = {
        inner = 4;
        outer = 8;
        smartGaps = "on";
      };

      window = {
        border = 2;
        titlebar = false;
      };

      floating = {
        border = 2;
        titlebar = false;
      };

      output."*".bg = "${wallpaper} fill";

      # Keep the native Sway bar independent from the disabled Stylix target.
      bars = [{position = "top";}];

      keybindings =
        {
          # Launchers
          "${mod}+Return" = "exec ${terminal}";
          "${mod}+d" = "exec ${launcher}";
          "${mod}+b" = "exec qutebrowser";
          "${mod}+Shift+f" = "exec pcmanfm";
          "${mod}+Ctrl+x" = "exec ${lock}";

          # Window management
          "${mod}+q" = "kill";
          "${mod}+f" = "fullscreen toggle";
          "${mod}+t" = "floating toggle";
          "${mod}+space" = "focus mode_toggle";
          "${mod}+Shift+Return" = "layout toggle split";
          "${mod}+Ctrl+q" = "exit";

          # Focus
          "${mod}+h" = "focus left";
          "${mod}+j" = "focus down";
          "${mod}+k" = "focus up";
          "${mod}+l" = "focus right";

          # Move windows
          "${mod}+Shift+h" = "move left";
          "${mod}+Shift+j" = "move down";
          "${mod}+Shift+k" = "move up";
          "${mod}+Shift+l" = "move right";

          # Resize
          "${mod}+Ctrl+h" = "resize shrink width 40 px";
          "${mod}+Ctrl+j" = "resize grow height 40 px";
          "${mod}+Ctrl+k" = "resize shrink height 40 px";
          "${mod}+Ctrl+l" = "resize grow width 40 px";

          # Multi-monitor control
          "${mod}+comma" = "focus output left";
          "${mod}+period" = "focus output right";
          "${mod}+Shift+comma" = "move container to output left";
          "${mod}+Shift+period" = "move container to output right";
          "${mod}+Ctrl+comma" = "move workspace to output left";
          "${mod}+Ctrl+period" = "move workspace to output right";

          # Screenshots
          "${mod}+Shift+s" = "exec ${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp})\" - | ${pkgs.wl-clipboard}/bin/wl-copy";

          # Media and brightness keys
          "XF86AudioRaiseVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86MonBrightnessUp" = "exec ${lib.getExe pkgs.brightnessctl} set 10%+";
          "XF86MonBrightnessDown" = "exec ${lib.getExe pkgs.brightnessctl} set 10%-";
        }
        // workspaceBindings;
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      show-failed-attempts = true;
      indicator-radius = 100;
    };
  };

  services.swayidle = {
    enable = true;

    events = {
      inherit lock;
      before-sleep = lock;
    };

    # Suspend/hibernate remains owned by logind in modules/power/dell.nix.
    timeouts = [
      {
        timeout = 300;
        command = lock;
      }
      {
        timeout = 330;
        command = ''${pkgs.sway}/bin/swaymsg "output * power off"'';
        resumeCommand = ''${pkgs.sway}/bin/swaymsg "output * power on"'';
      }
    ];
  };
}
