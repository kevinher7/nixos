{
  lib,
  pkgs,
  osFamily,
  ...
}: {
  imports =
    [./git.nix ./direnv.nix]
    ++ lib.optional (osFamily == "linux") ./linux
    ++ lib.optional (osFamily == "darwin") ./darwin;

  programs.home-manager.enable = true;

  home = {
    stateVersion = "25.11";

    packages = with pkgs; [
      btop
      tree
      curl
      pfetch
    ];
  };
}
