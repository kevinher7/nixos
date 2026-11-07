{
  config,
  lib,
  ...
}: let
  gruvbox = {
    background = "#1d2021";
    backgroundSoft = "#282828";
    raised = "#3c3836";
    selected = "#504945";
    muted = "#928374";
    foreground = "#ebdbb2";
    red = "#fb4934";
    green = "#b8bb26";
    yellow = "#fabd2f";
    blue = "#83a598";
    purple = "#d3869b";
    aqua = "#8ec07c";
    orange = "#fe8019";
  };
in {
  config = lib.mkIf config.myPrograms.qutebrowser.enable {
    stylix.targets.qutebrowser.enable = false;

    programs.qutebrowser.settings.colors = with gruvbox; {
      completion = {
        fg = foreground;
        odd.bg = background;
        even.bg = backgroundSoft;
        category = {
          fg = yellow;
          bg = raised;
          border.top = raised;
          border.bottom = raised;
        };
        item.selected = {
          fg = foreground;
          bg = selected;
          border.top = selected;
          border.bottom = selected;
          match.fg = orange;
        };
        match.fg = yellow;
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
        bar.bg = background;
        indicator.start = blue;
        indicator.stop = green;
        indicator.error = red;
        indicator.system = "rgb";
        odd.fg = foreground;
        odd.bg = backgroundSoft;
        even.fg = foreground;
        even.bg = raised;
        selected.odd.fg = yellow;
        selected.odd.bg = selected;
        selected.even.fg = yellow;
        selected.even.bg = selected;
        pinned.odd.fg = aqua;
        pinned.odd.bg = backgroundSoft;
        pinned.even.fg = aqua;
        pinned.even.bg = raised;
        pinned.selected.odd.fg = yellow;
        pinned.selected.odd.bg = selected;
        pinned.selected.even.fg = yellow;
        pinned.selected.even.bg = selected;
      };

      webpage.bg = background;
      webpage.preferred_color_scheme = "dark";
    };
  };
}
