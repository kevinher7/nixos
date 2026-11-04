{lib, ...}: let
  devicesType = lib.types.attrsOf (lib.types.nonEmptyListOf lib.types.nonEmptyStr);
in {
  options.myDevices.devices = {
    private = lib.mkOption {
      type = devicesType;
      description = "Personal devices allowed on private websites.";
    };

    vaultGuests = lib.mkOption {
      type = devicesType;
      description = "Guest devices eligible for Vault access.";
    };
  };
}
