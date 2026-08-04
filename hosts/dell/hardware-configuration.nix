# ⚠️  PLACEHOLDER — NOT THE REAL HARDWARE CONFIGURATION ⚠️
#
# Every device UUID below is fake. This file exists so the flake evaluates and
# CI can build `kebean` before the machine is provisioned.
#
# On the Dell, BEFORE the first `nixos-rebuild switch`, replace this file
# wholesale with the generated one:
#
#     nixos-generate-config --show-hardware-config > \
#       ~/nixos-config/hosts/dell/hardware-configuration.nix
#
# Rebuilding with these placeholder UUIDs will install a boot entry pointing at
# a root device that does not exist, and the machine will not boot.
{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000"; # PLACEHOLDER
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0000-0000"; # PLACEHOLDER
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  swapDevices = [];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
