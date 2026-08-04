{
  hostname,
  profile,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/desktop/hyprland
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

  myVars = {
    gitUser = {
      name = "Kevin Hernandez";
      email = "kevinhernem@gmail.com";
    };

    opencodePort = 4096;
  };

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

    # Hyprland is a Wayland session, so fcitx5 uses its Wayland frontend here
    # rather than the X11 one the qtile hosts rely on.
    input.waylandFrontend = true;
  };

  # AMD Radeon integrated graphics.
  hardware.enableRedistributableFirmware = true;
}
