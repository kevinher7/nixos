{osConfig, ...}: {
  programs.git = {
    enable = true;
    ignores = [".DS_Store"]; # global gitignore
    settings = {
      user.name = osConfig.myVars.gitUser.name;
      user.email = osConfig.myVars.gitUser.email;
      init.defaultBranch = "main";
      core.editor = "nvim";
    };
  };
}
