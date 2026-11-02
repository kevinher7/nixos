{
  config,
  lib,
  ...
}: let
  cfg = config.myHomelab.webAccess;
  privateClients = ["127.0.0.1" "::1"] ++ cfg.privateClients;
  accessRules = clients:
    lib.concatMapStrings (address: "allow ${address};\n") clients + "deny all;\n";
in {
  options.myHomelab.webAccess = {
    enable = lib.mkEnableOption "private-by-default nginx websites with explicit guest access";

    privateClients = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Device IPv4 and IPv6 addresses allowed on every website. Loopback is always allowed.";
    };

    sharedHosts = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      default = {};
      example = {"vault.example.com" = ["100.64.0.20"];};
      description = "Guest device addresses allowed on each nginx website. Other websites stay private.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      commonHttpConfig = accessRules privateClients;
      virtualHosts =
        lib.mapAttrs (_: clients: {
          extraConfig = accessRules (privateClients ++ clients);
        })
        cfg.sharedHosts
        // {
          "_" = {
            default = true;
            rejectSSL = true;
            locations."/".return = "444";
          };
        };
    };
  };
}
