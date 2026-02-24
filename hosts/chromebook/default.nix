{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/packages.nix
    ../../modules/networking.nix
    ../../modules/programs.nix
    ../../modules/stylix.nix
    ../../modules/display
    ../../modules/input
    ../../modules/audio
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "beans-btw";

  time.timeZone = "Asia/Tokyo";
}
