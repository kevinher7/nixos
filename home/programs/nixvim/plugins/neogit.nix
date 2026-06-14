{
  programs.nixvim = {
    plugins.neogit = {
      enable = true;
      settings = {
        kind = "floating";
        integrations.diffview = true;
        commit_editor.spell_check = false;
      };
    };
  };
}
