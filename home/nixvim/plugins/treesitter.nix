{ pkgs, ... }:
{
  programs.nixvim = {
    plugins = {
      treesitter = {
        enable = true;

        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          bash
          nix
          query
          yaml

          python
          c

          typst
        ];

        settings = {
          highlight.enable = true;
          indent.enable = true;

          textobjects = {
            select = {
              enable = true;
              keymaps = {
                "af" = "@function.outer";
                "if" = "@function.inner";
                "ac" = "@class.outer";
                "ic" = "@class.inner";
              };
            };
          };
        };
      };
    };
  };
}
