_:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/packages.nix
    ../../modules/networking.nix
    ../../modules/programs.nix
    ../../modules/stylix.nix
    ../../modules/desktop/qtile
    ../../modules/login
    ../../modules/input
    ../../modules/audio
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "beans-btw";

  time.timeZone = "Asia/Tokyo";

  services.logind.powerKey = "suspend";
  security.pam.services.betterlockscreen.enable = true;
}
