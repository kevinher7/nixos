{
  programs.nixvim = {
    plugins.git-conflict = {
      enable = true;
      settings = {
        default_mappings = true;
        disable_diagnostics = true;
      };
    };
  };
}
