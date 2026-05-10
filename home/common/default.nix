{
  lib,
  pkgs,
  username,
  config,
  ...
}: {
  imports =
    [
      ./git.nix
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [./linux]
    ++ lib.optionals pkgs.stdenv.isDarwin [./darwin];

  programs.home-manager.enable = true;

  home = {
    inherit username;
    homeDirectory = lib.mkForce (
      if pkgs.stdenv.isDarwin
      then "/Users/${username}"
      else "/home/${username}"
    );
    stateVersion = "25.11";

    packages = with pkgs; [
      btop
      tree
      gh
      curl
      pfetch
    ];
  };

  # Silence GTK4 theme warning while on stateVersion < 26.05
  gtk.gtk4.theme = config.gtk.theme;
}
