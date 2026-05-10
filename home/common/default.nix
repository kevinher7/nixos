{
  lib,
  pkgs,
  username,
  config,
  ...
}: {
  imports = [
    ./git.nix
    ./linux
    ./darwin
  ];

  options.myHome.os = lib.mkOption {
    type = lib.types.enum ["linux" "darwin"];
    description = "Target operating system for this home configuration";
  };

  config = {
    programs.home-manager.enable = true;

    home = {
      inherit username;
      homeDirectory = lib.mkForce (
        if config.myHome.os == "darwin"
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
  };
}
