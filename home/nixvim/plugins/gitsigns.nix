{
  programs.nixvim = {
    plugins = {
      gitsigns = {
        enable = true;
        settings = {
          signs = {
            add.text = "+";
            change.text = "~";
            changedelete.text = "~";
            delete.text = "_";
            topdelete.text = "‾";
            untracked.text = "┆";
          };
          current_line_blame = true;
          current_line_blame_opts = {
            delay = 200;
          };
        };
      };
      # TODO: Implement keymaps for in-editor git tracking
    };
  };
}
