_: {
  imports = [../common ../programs];

  myPrograms = {
    ghostty.enable = true;
    nixvim.enable = true;
    opencode.enable = true;
    t3code = {
      cli.enable = true;
      desktop.enable = true;
    };
    tmux.enable = true;
    zen-browser.enable = true;
  };
}
