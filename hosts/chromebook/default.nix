{ pkgs, ... }:
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

  programs.i3lock.enable = true;

  services = {
    logind.powerKey = "suspend";
    xserver.displayManager.sessionCommands = ''
      ${pkgs.xss-lock}/bin/xss-lock -- ${pkgs.i3lock-color}/bin/i3lock-color --color=2e3440 --clock --time-color=d8dee9 --date-color=d8dee9 &
    '';
  };

  security.pam.services.i3lock-color.enable = true;
}
