_: {
  imports = [../common ../programs];

  myPrograms = {
    ghostty.enable = true;
    nixvim.enable = true;
    agents = {
      codex.enable = true;
      opencode.enable = true;
    };
    t3code.cli.enable = true;
  };
}
