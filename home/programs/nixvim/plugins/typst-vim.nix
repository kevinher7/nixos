{
  programs.nixvim = {
    plugins.typst-vim = {
      enable = true;

      keymaps = {
        watch = "<leader>w";
      };
    };
  };
}
