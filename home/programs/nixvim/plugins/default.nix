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
    ./transparent.nix
    ./lualine.nix
    ./nvim-autopairs.nix
    ./which-key.nix
    ./claude-assistant.nix
  ];

  programs.nixvim = {
    # nixvim builds plugins from its own pinned nixpkgs (it intentionally does
    # not follow ours, and useGlobalPackages is off), so the host's allowUnfree
    # settings don't reach it.
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "git-conflict.nvim"
        "transparent.nvim"
        "claude-code"
      ];

    plugins = {
      web-devicons.enable = true;
      none-ls.enable = true;

      guess-indent.enable = true;
      nvim-surround.enable = true;
    };
  };
}
