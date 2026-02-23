{ ... }:
{
  imports = [
    ./telescope.nix
    ./lsp.nix
    ./treesitter.nix
    ./gitsigns.nix
    ./indent-blankline.nix
    ./typst-vim.nix
    ./blink-cmp.nix
    ./lualine.nix
    ./nvim-autopairs.nix
  ];

  programs.nixvim = {
    plugins = {
      transparent.enable = true;
      web-devicons.enable = true;
      none-ls.enable = true;

      guess-indent.enable = true;
      nvim-surround.enable = true;
    };
  };
}
