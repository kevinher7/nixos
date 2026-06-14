{
  programs.nixvim = {
    # Colorscheme is managed by Stylix and it has no
    # transparency option for floating windows or plugin
    plugins.transparent = {
      enable = true;
      settings.extra_groups = [
        "NormalFloat"
        "FloatBorder"
        "Pmenu"
        "PmenuSel"
      ];
    };

    # clear_prefix nukes the background of whole plugin highlight families
    # in one shot (avoids enumerating every Telescope*/Diffview* group).
    # Runs last so the groups already exist when we clear them.
    extraConfigLuaPost = ''
      local ok, transparent = pcall(require, "transparent")
      if ok then
        transparent.clear_prefix("Telescope")
        transparent.clear_prefix("Diffview")
        transparent.clear_prefix("BlinkCmp")
      end

      -- mini.base16 (Stylix's colorscheme) sets NormalNC with an opaque
      -- base00 background, and Stylix's transparentBackground.main only
      -- clears Normal — not NormalNC. So non-current windows (e.g. Diffview's
      -- diff editor panes when the file panel is focused) render opaque.
      -- Clear it so inactive windows are transparent too.
      vim.api.nvim_set_hl(0, "NormalNC", { bg = "none", ctermbg = "none" })
    '';
  };
}
