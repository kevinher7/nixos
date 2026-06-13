{
  programs.nixvim = {
    # Magit-style Source Control panel: stage/commit/branch/stash.
    # Press `d` on a file to open it in diffview.
    plugins.neogit = {
      enable = true;
      settings = {
        kind = "floating";
        integrations.diffview = true;
      };
    };
  };
}
