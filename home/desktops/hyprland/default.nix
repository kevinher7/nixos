{
  lib,
  config,
  pkgs,
  ...
}: let
  mod = "SUPER";
  terminal = lib.getExe config.programs.alacritty.package;
  launcher = "${lib.getExe config.programs.rofi.finalPackage} -show drun";
  lock = lib.getExe config.programs.hyprlock.package;

  inherit (lib.generators) mkLuaInline;

  # Under configType = "lua", `settings.<name>` renders as `hl.<name>(...)` and a
  # list value renders one call per element. `_args` turns an entry into a
  # multi-argument call, and mkLuaInline emits a raw Lua expression rather than a
  # quoted string — dispatchers are expressions, so they need it.
  bind = keys: dispatcher: {
    _args = [keys (mkLuaInline dispatcher)];
  };

  # The old binde/bindl/bindel/bindm flavours are all `hl.bind` plus a flag table.
  bindOpts = keys: dispatcher: opts: {
    _args = [keys (mkLuaInline dispatcher) opts];
  };

  exec = cmd: "hl.dsp.exec_cmd(${builtins.toJSON cmd})";

  workspaceBinds = lib.concatLists (lib.genList (i: let
      ws = toString (i + 1);
    in [
      (bind "${mod} + ${ws}" "hl.dsp.focus({ workspace = ${ws} })")
      (bind "${mod} + SHIFT + ${ws}" "hl.dsp.window.move({ workspace = ${ws} })")
    ])
    9);
in {
  imports = [./waybar.nix];

  wayland.windowManager.hyprland = {
    enable = true;

    configType = "lua";

    settings = {
      monitor = {
        output = "";
        mode = "preferred";
        position = "auto";
        scale = 1;
      };

      config = {
        input = {
          kb_layout = "jp";
          repeat_delay = 400;
          repeat_rate = 35;

          touchpad = {
            natural_scroll = true;
            disable_while_typing = true;
            tap_to_click = true;
          };
        };

        general = {
          gaps_in = 4;
          gaps_out = 8;
          border_size = 2;
          layout = "dwindle";
        };

        dwindle = {
          # Required by the `hl.dsp.layout("togglesplit")` bind below.
          preserve_split = true;
        };

        misc = {
          # Stylix/hyprpaper own the background; Hyprland's built-in one would
          # only flash on startup.
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };
      };

      bind =
        [
          # Launchers — same keys as the qtile config
          (bind "${mod} + Return" (exec terminal))
          (bind "${mod} + D" (exec launcher))
          (bind "${mod} + B" (exec "qutebrowser"))
          (bind "${mod} + SHIFT + F" (exec "pcmanfm"))
          # Not ${mod} + CTRL + L: that collides with the resize bind below, and
          # Hyprland fires every bind on a chord rather than picking one.
          (bind "${mod} + CTRL + X" (exec lock))

          # Window management
          (bind "${mod} + Q" "hl.dsp.window.close()")
          (bind "${mod} + F" "hl.dsp.window.fullscreen()")
          (bind "${mod} + T" ''hl.dsp.window.float({ action = "toggle" })'')
          (bind "${mod} + Space" "hl.dsp.window.cycle_next()")
          # `togglesplit` stopped being a dispatcher in 0.54; it is a dwindle
          # layout message now.
          (bind "${mod} + SHIFT + Return" ''hl.dsp.layout("togglesplit")'')
          (bind "${mod} + CTRL + Q" "hl.dsp.exit()")

          # Focus (vim keys, as in qtile)
          (bind "${mod} + H" ''hl.dsp.focus({ direction = "l" })'')
          (bind "${mod} + J" ''hl.dsp.focus({ direction = "d" })'')
          (bind "${mod} + K" ''hl.dsp.focus({ direction = "u" })'')
          (bind "${mod} + L" ''hl.dsp.focus({ direction = "r" })'')

          # Move windows
          (bind "${mod} + SHIFT + H" ''hl.dsp.window.move({ direction = "l" })'')
          (bind "${mod} + SHIFT + J" ''hl.dsp.window.move({ direction = "d" })'')
          (bind "${mod} + SHIFT + K" ''hl.dsp.window.move({ direction = "u" })'')
          (bind "${mod} + SHIFT + L" ''hl.dsp.window.move({ direction = "r" })'')

          # Screenshots
          (bind "${mod} + SHIFT + S" (exec ''${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp})" - | ${pkgs.wl-clipboard}/bin/wl-copy''))

          # Resize — the old `binde`, i.e. repeat while held
          (bindOpts "${mod} + CTRL + H" "hl.dsp.window.resize({ x = -40, y = 0, relative = true })" {repeating = true;})
          (bindOpts "${mod} + CTRL + J" "hl.dsp.window.resize({ x = 0, y = 40, relative = true })" {repeating = true;})
          (bindOpts "${mod} + CTRL + K" "hl.dsp.window.resize({ x = 0, y = -40, relative = true })" {repeating = true;})
          (bindOpts "${mod} + CTRL + L" "hl.dsp.window.resize({ x = 40, y = 0, relative = true })" {repeating = true;})

          # Media and brightness keys — the old `bindel`, i.e. locked + repeating
          (bindOpts "XF86AudioRaiseVolume" (exec "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+") {
            locked = true;
            repeating = true;
          })
          (bindOpts "XF86AudioLowerVolume" (exec "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-") {
            locked = true;
            repeating = true;
          })
          # `light` is X11-only; brightnessctl is the Wayland equivalent.
          (bindOpts "XF86MonBrightnessUp" (exec "${lib.getExe pkgs.brightnessctl} set 10%+") {
            locked = true;
            repeating = true;
          })
          (bindOpts "XF86MonBrightnessDown" (exec "${lib.getExe pkgs.brightnessctl} set 10%-") {
            locked = true;
            repeating = true;
          })

          # The old `bindl` — works while the lockscreen is up
          (bindOpts "XF86AudioMute" (exec "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") {locked = true;})

          # Super + left/right drag, matching the qtile mouse bindings
          (bindOpts "${mod} + mouse:272" "hl.dsp.window.drag()" {mouse = true;})
          (bindOpts "${mod} + mouse:273" "hl.dsp.window.resize()" {mouse = true;})
        ]
        ++ workspaceBinds;
    };
  };

  services.hyprpaper.enable = true;

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || ${lock}";
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

      background = {
        blur_passes = 2;
        blur_size = 8;
      };

      input-field = {
        size = "300, 50";
        position = "0, -80";
        halign = "center";
        valign = "center";
        fade_on_empty = false;
        placeholder_text = "";
      };
    };
  };
}
