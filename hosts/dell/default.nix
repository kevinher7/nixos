{
  lib,
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
    ../../modules/t3code
  ];

  time.timeZone = "Asia/Tokyo";

  programs.steam.enable = true;

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-unwrapped"
    ];

  myVars = {
    gitUser = {
      name = "Kevin Hernandez";
      email = "kevinhernem@gmail.com";
    };

    opencodePort = 4096;
  };

  myModules = {
    theming.wallpaper = ../../assets/wallpapers/orion-nebula.jpg;

    input.waylandFrontend = true;

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

  # AMD Radeon integrated graphics.
  hardware.enableRedistributableFirmware = true;
}
