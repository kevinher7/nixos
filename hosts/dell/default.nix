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
    ../../modules/programs
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
    programs.steam.enable = true;

    theming.wallpaper = ../../assets/wallpapers/orion-nebula.jpg;

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
