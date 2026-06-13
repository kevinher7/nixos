{lib, ...}: {
  imports = [
    ./telescope.nix
    ./lsp.nix
    ./lint.nix
    ./treesitter.nix
    ./gitsigns.nix
    ./neo-tree.nix
    ./diffview.nix
    ./git-conflict.nix
    ./neogit.nix
    ./indent-blankline.nix
    ./typst-vim.nix
    ./blink-cmp.nix
    ./lualine.nix
    ./nvim-autopairs.nix
    ./which-key.nix
  ];

  programs.nixvim = {
    # nixvim builds plugins from its own pinned nixpkgs (it intentionally does
    # not follow ours, and useGlobalPackages is off), so the host's allowUnfree
    # settings don't reach it. git-conflict.nvim is flagged unfree there over a
    # licensing quirk, so whitelist just that package in nixvim's own nixpkgs.
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "git-conflict.nvim"
      ];

    plugins = {
      web-devicons.enable = true;
      none-ls.enable = true;

      guess-indent.enable = true;
      nvim-surround.enable = true;
    };
  };
}
