{
  hostname,
  profile,
  ...
}: {
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

  time.timeZone = "Asia/Tokyo";

  myVars = {
    gitUser = {
      name = "Kevin Hernandez";
      email = "kevinhernem@gmail.com";
    };
  };

  myModules = {
    theming.wallpaper = ../../assets/wallpapers/girl-reading-book.png;

    networking = {
      enable = true;
      inherit hostname;
      tailscale = {
        enable = true;
        ssh = false;
        operatorUser = "kevin";
      };
    };

    power = {
      enable = true;
      inherit profile;
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
