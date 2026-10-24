{lib, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/desktop/qtile
    ../../modules/system
    ../../modules/core
    ../../modules/theming
    ../../modules/networking
    ../../modules/login
    ../../modules/power
    ../../modules/input
    ../../modules/audio
    ../../modules/t3code
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    lib.getName pkg == "widevine-cdm";

  myModules = {
    power.profile = "laptop";

    theming.wallpaper = ../../assets/wallpapers/girl-reading-book.png;

    networking = {
      enable = true;
      tailscale = {
        enable = true;
        ssh = false;
        operatorUser = "kevin";
      };
      ssh.authorizedClients = ["kebee" "kebean" "uribo-btw"];
    };

    t3code = {
      enable = true;
      tailscaleServe.enable = true;
    };
  };

  programs.i3lock.enable = true;
  hardware.acpilight.enable = true;

  security.pam.services.i3lock-color.enable = true;
}
