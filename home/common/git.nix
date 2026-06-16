{osConfig, ...}: {
  programs.git = {
    enable = true;
    settings = {
      user.name = osConfig.myVars.gitUser.name;
      user.email = osConfig.myVars.gitUser.email;
      init.defaultBranch = "main";
      core.editor = "nvim";
    };
  };
}
