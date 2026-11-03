{
  config,
  lib,
  ...
}: {
  options.myDevices = {
    devices = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options.addresses = lib.mkOption {
          type = lib.types.nonEmptyListOf lib.types.nonEmptyStr;
          description = "Tailscale IPv4 and IPv6 addresses of this device.";
        };
      });
      description = "Named devices, including machines not managed by this flake.";
    };

    groups = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf (lib.types.enum (builtins.attrNames config.myDevices.devices)));
      description = "Named groups of registered devices. Membership alone grants no access.";
    };
  };
}
