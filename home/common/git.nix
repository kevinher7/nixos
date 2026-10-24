_: {
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };

  programs.git = {
    enable = true;
    ignores = [".DS_Store"]; # global gitignore
    settings = {
      user.name = "Kevin Hernandez";
      user.email = "kevinhernem@gmail.com";
      init.defaultBranch = "main";
      core.editor = "nvim";
    };
  };
}
