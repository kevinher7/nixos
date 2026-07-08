{config, ...}: {
  programs.nixvim = {
    plugins = {
      treesitter = {
        enable = true;

        # Use nixvim's treesitter package: grammars from other nixpkgs instances ship queries Neovim can't parse.
        grammarPackages = with config.programs.nixvim.plugins.treesitter.package.builtGrammars; [
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
        };
      };

      treesitter-textobjects = {
        enable = true;

        settings = {
          select = {
            enable = true;
            lookahead = true;
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
}
