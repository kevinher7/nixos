_: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/desktop/qtile
    ../../modules/system
    ../../modules/core
    ../../modules/theming
    ../../modules/networking
    ../../modules/login
    ../../modules/power/laptop.nix
    ../../modules/input
    ../../modules/audio
    ../../modules/t3code
  ];

  myModules = {
    theming.wallpaper = ../../assets/wallpapers/girl-reading-book.png;

    networking = {
      enable = true;
      tailscale = {
        enable = true;
        ssh = false;
        operatorUser = "kevin";
      };
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
