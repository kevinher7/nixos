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
  ];

  time.timeZone = "Asia/Tokyo";

  myModules = {
    networking = {
      enable = true;
      inherit hostname;
      tailscale = {
        enable = true;
        ssh = false;
      };
    };

    power = {
      enable = true;
      inherit profile;
    };
  };

  programs = {
    i3lock.enable = true;
    light.enable = true;
  };

  security.pam.services.i3lock-color.enable = true;
}
