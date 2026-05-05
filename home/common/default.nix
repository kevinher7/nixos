{
  lib,
  pkgs,
  username,
  config,
  ...
}: {
  imports = [
    ./git.nix
    ./bash.nix
    ./rofi.nix
    ./stylix.nix
  ];

  programs.home-manager.enable = true;

  home = {
    inherit username;
    homeDirectory = lib.mkForce "/home/${username}";
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
