{
  config,
  lib,
  pkgs,
  ...
}: let
  tokyoNight = {
    background = "#1a1b26";
    backgroundSoft = "#16161e";
    raised = "#24283b";
    selected = "#283457";
    muted = "#565f89";
    foreground = "#c0caf5";
    red = "#f7768e";
    green = "#9ece6a";
    yellow = "#e0af68";
    blue = "#7aa2f7";
    purple = "#bb9af7";
    aqua = "#7dcfff";
    orange = "#ff9e64";
  };
in {
  config = lib.mkIf config.myPrograms.qutebrowser.enable {
    stylix.targets.qutebrowser.enable = false;

    programs.qutebrowser.settings.qt.args = [
      "stylesheet=${pkgs.writeText "qutebrowser-tabs.qss" ''
        TabBar {
          border-right: 1px solid ${tokyoNight.muted};
        }
      ''}"
    ];

    programs.qutebrowser.settings.colors = with tokyoNight; {
      completion = {
        fg = foreground;
        odd.bg = background;
        even.bg = backgroundSoft;
        category = {
          fg = blue;
          bg = raised;
          border.top = raised;
          border.bottom = raised;
        };
        item.selected = {
          fg = foreground;
          bg = selected;
          border.top = selected;
          border.bottom = selected;
          match.fg = aqua;
        };
        match.fg = blue;
        scrollbar.fg = muted;
        scrollbar.bg = background;
      };

      contextmenu = {
        menu.fg = foreground;
        menu.bg = backgroundSoft;
        selected.fg = foreground;
        selected.bg = selected;
        disabled.fg = muted;
        disabled.bg = backgroundSoft;
      };
      tooltip.fg = foreground;
      tooltip.bg = raised;

      downloads = {
        bar.bg = background;
        start.fg = background;
        start.bg = blue;
        stop.fg = background;
        stop.bg = green;
        error.fg = background;
        error.bg = red;
        system.fg = "rgb";
        system.bg = "rgb";
      };

      hints = {
        fg = background;
        bg = yellow;
        match.fg = red;
      };
      keyhint = {
        fg = foreground;
        bg = raised;
        suffix.fg = yellow;
      };

      messages = {
        error.fg = background;
        error.bg = red;
        error.border = red;
        warning.fg = background;
        warning.bg = yellow;
        warning.border = yellow;
        info.fg = foreground;
        info.bg = backgroundSoft;
        info.border = blue;
      };

      prompts = {
        fg = foreground;
        bg = backgroundSoft;
        border = "1px solid ${muted}";
        selected.fg = foreground;
        selected.bg = selected;
      };

      statusbar = {
        normal.fg = foreground;
        normal.bg = background;
        insert.fg = background;
        insert.bg = green;
        passthrough.fg = background;
        passthrough.bg = blue;
        private.fg = background;
        private.bg = purple;
        command.fg = foreground;
        command.bg = backgroundSoft;
        command.private.fg = purple;
        command.private.bg = backgroundSoft;
        caret.fg = background;
        caret.bg = aqua;
        caret.selection.fg = background;
        caret.selection.bg = orange;
        progress.bg = blue;
        url.fg = foreground;
        url.error.fg = red;
        url.hover.fg = aqua;
        url.success.http.fg = yellow;
        url.success.https.fg = green;
        url.warn.fg = orange;
      };

      tabs = {
        bar.bg = "#b31a1b26";
        indicator.start = blue;
        indicator.stop = green;
        indicator.error = red;
        indicator.system = "rgb";
        odd.fg = foreground;
        odd.bg = "transparent";
        even.fg = foreground;
        even.bg = "transparent";
        selected.odd.fg = background;
        selected.odd.bg = blue;
        selected.even.fg = background;
        selected.even.bg = blue;
        pinned.odd.fg = aqua;
        pinned.odd.bg = "transparent";
        pinned.even.fg = aqua;
        pinned.even.bg = "transparent";
        pinned.selected.odd.fg = background;
        pinned.selected.odd.bg = aqua;
        pinned.selected.even.fg = background;
        pinned.selected.even.bg = aqua;
      };

      webpage.bg = background;
      webpage.preferred_color_scheme = "dark";
    };
  };
}
