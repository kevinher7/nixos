{
  config,
  lib,
  ...
}: let
  aerospace = lib.getExe config.programs.aerospace.package;
  joinNewWindow = direction: ''
    exec-and-forget workspace="$(${aerospace} echo --window-id "$AEROSPACE_WINDOW_ID" -- '%{workspace}')" &&
      [ "$(${aerospace} list-windows --workspace "$workspace" --count)" -gt 2 ] &&
      ${aerospace} join-with --window-id "$AEROSPACE_WINDOW_ID" ${direction}
  '';
  modeForFocusedApp = ''
    exec-and-forget if [ "$(${aerospace} list-windows --focused --format '%{app-bundle-id}')" = "app.zen-browser.zen" ]; then
        ${aerospace} mode browser
      else
        ${aerospace} mode main
      fi
  '';
  mainBindings = {
    cmd-enter = "exec-and-forget osascript -e 'tell application \"Ghostty\" to new window'";
    alt-shift-semicolon = "mode service";
    alt-h = "focus --boundaries-action wrap-around-the-workspace left";
    alt-j = "focus --boundaries-action wrap-around-the-workspace down";
    alt-k = "focus --boundaries-action wrap-around-the-workspace up";
    alt-l = "focus --boundaries-action wrap-around-the-workspace right";
    alt-shift-h = "join-with left";
    alt-shift-j = "join-with down";
    alt-shift-k = "join-with up";
    alt-shift-l = "join-with right";
    alt-f = "fullscreen";
    alt-s = "layout v_accordion";
    alt-w = "layout h_accordion";
    alt-e = "layout tiles horizontal vertical";
    alt-shift-space = "layout floating tiling";
    alt-1 = "workspace 1";
    alt-2 = "workspace 2";
    alt-3 = "workspace 3";
    alt-4 = "workspace 4";
    alt-5 = "workspace 5";
    alt-6 = "workspace 6";
    alt-7 = "workspace 7";
    alt-8 = "workspace 8";
    alt-9 = "workspace 9";
    alt-0 = "workspace 10";
    alt-r = "workspace R";
    alt-t = "workspace T";
    alt-y = "workspace Y";
    alt-c = "workspace C";
    alt-shift-1 = "move-node-to-workspace 1";
    alt-shift-2 = "move-node-to-workspace 2";
    alt-shift-3 = "move-node-to-workspace 3";
    alt-shift-4 = "move-node-to-workspace 4";
    alt-shift-5 = "move-node-to-workspace 5";
    alt-shift-6 = "move-node-to-workspace 6";
    alt-shift-7 = "move-node-to-workspace 7";
    alt-shift-8 = "move-node-to-workspace 8";
    alt-shift-9 = "move-node-to-workspace 9";
    alt-shift-0 = "move-node-to-workspace 10";
    alt-shift-r = "move-node-to-workspace R";
    alt-shift-t = "move-node-to-workspace T";
    alt-shift-y = "move-node-to-workspace Y";
    alt-shift-c = "move-node-to-workspace C";
    alt-shift-m = "reload-config";
    alt-shift-tab = "move-workspace-to-monitor --wrap-around next";
  };
in {
  config = lib.mkIf config.myPrograms.aerospace.enable {
    xdg.enable = true;

    programs.aerospace = {
      enable = true;
      launchd.enable = true;
      settings = {
        config-version = 2;
        persistent-workspaces = [];
        default-root-container-layout = "tiles";
        default-root-container-orientation = "horizontal";
        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;
        on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];
        on-window-detected = [
          {
            "if" = "test %{window-parent-container-layout} = h_tiles";
            run = joinNewWindow "left";
          }
          {
            "if" = "test %{window-parent-container-layout} = v_tiles";
            run = joinNewWindow "up";
          }
        ];

        on-focus-changed = [modeForFocusedApp];
        mode.main.binding = mainBindings;
        mode.browser.binding = builtins.removeAttrs mainBindings ["cmd-enter"];

        mode.resize.binding = {
          h = "resize width -50";
          j = "resize height +50";
          k = "resize height -50";
          l = "resize width +50";
          enter = modeForFocusedApp;
          esc = modeForFocusedApp;
        };

        mode.service.binding = {
          esc = ["reload-config" modeForFocusedApp];
          r = ["flatten-workspace-tree" modeForFocusedApp];
          f = ["layout floating tiling" modeForFocusedApp];
          alt-shift-h = ["join-with left" modeForFocusedApp];
          alt-shift-j = ["join-with down" modeForFocusedApp];
          alt-shift-k = ["join-with up" modeForFocusedApp];
          alt-shift-l = ["join-with right" modeForFocusedApp];
        };

        gaps = {
          inner.horizontal = 5;
          inner.vertical = 5;
          outer.top = 5;
          outer.bottom = 5;
          outer.left = 5;
          outer.right = 5;
        };
      };
    };
  };
}
