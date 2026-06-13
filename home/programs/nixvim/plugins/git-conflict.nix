{
  programs.nixvim = {
    # Inline conflict resolution on the <<<<<<< markers (VS Code CodeLens feel).
    # Default buffer-local mappings while on a conflict:
    #   co = choose ours    ct = choose theirs
    #   cb = choose both     c0 = choose none
    #   ]x / [x = next / previous conflict
    plugins.git-conflict = {
      enable = true;
      settings = {
        default_mappings = true;
        disable_diagnostics = true;
      };
    };
  };
}
