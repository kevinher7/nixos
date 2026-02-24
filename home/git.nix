_:
{
  programs.git = {
    enable = true;
    userName = "Kevin Hernandez";
    userEmail = "kevinhernem@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}
