{
  programs.nixvim = {
    # Full-screen diff browser and 3-way merge tool.
    # `:DiffviewOpen` during a merge gives OURS | base | THEIRS with
    # <leader>co/ct/cb to choose a side and ]x / [x to jump conflicts.
    plugins.diffview.enable = true;
  };
}
