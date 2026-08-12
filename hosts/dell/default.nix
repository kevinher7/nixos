{
  hostname,
  profile,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/desktop/sway
    ../../modules/system
    ../../modules/core
    ../../modules/theming
    ../../modules/networking
    ../../modules/login
    ../../modules/power
    ../../modules/input
    ../../modules/audio
    ../../modules/bluetooth
  ];

  time.timeZone = "Asia/Tokyo";

  myVars = {
    gitUser = {
      name = "Kevin Hernandez";
      email = "kevinhernem@gmail.com";
    };

    opencodePort = 4096;
  };

  myModules = {
    input.waylandFrontend = true;

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

  # AMD Radeon integrated graphics.
  hardware.enableRedistributableFirmware = true;
}
