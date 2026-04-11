{ hostname, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/packages.nix
    ../../modules/programs.nix
    ../../modules/stylix.nix
    ../../modules/desktop/qtile
    ../../modules/networking
    ../../modules/login
    ../../modules/input
    ../../modules/audio
  ];


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  myModules.networking = {
    enable = true;
    hostname = hostname;
    tailscale = {
      enable = true;
      ssh = false;
    };
  };

  time.timeZone = "Asia/Tokyo";

  programs.i3lock.enable = true;

  services.logind.powerKey = "suspend";
  security.pam.services.i3lock-color.enable = true;
}
