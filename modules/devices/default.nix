{lib, ...}: {
  options.myDevices.devices = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        addresses = lib.mkOption {
          type = lib.types.nonEmptyListOf lib.types.nonEmptyStr;
          description = "Tailscale IPv4 and IPv6 addresses of this device.";
        };

        groups = lib.mkOption {
          type = lib.types.nonEmptyListOf (lib.types.enum (import ./groups.nix));
          description = "Access groups this device belongs to.";
        };
      };
    });
    description = "Named devices and their membership in the fixed access groups.";
  };
}
