{
  programs.nixvim = {
    plugins.neo-tree = {
      enable = true;

      settings = {
        enable_git_status = true;
        enable_diagnostics = true;

        filesystem = {
          hijack_netrw_behavior = "open_current";
          follow_current_file.enabled = true;
          use_libuv_file_watcher = true;
        };

        window = {
          width = 32;
          position = "right";
        };
      };
    };
  };
}
