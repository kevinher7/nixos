{
  config,
  lib,
  ...
}: let
  cfg = config.myHomelab.webAccess;
  privateClients = ["127.0.0.1" "::1"] ++ cfg.privateClients;
  accessRules = clients:
    lib.concatMapStrings (address: "allow ${address};\n") clients + "deny all;\n";
  guestNames = lib.unique (lib.concatLists (lib.attrValues cfg.sharedHosts));
in {
  options.myHomelab.webAccess = {
    enable = lib.mkEnableOption "private-by-default nginx websites with explicit guest access";

    privateClients = lib.mkOption {
      type = lib.types.listOf (lib.types.strMatching "[0-9a-fA-F:.]+");
      default = [];
      description = "Device IPv4 and IPv6 addresses allowed on every website. Loopback is always allowed.";
    };

    guests = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf (lib.types.strMatching "[0-9a-fA-F:.]+"));
      default = {};
      description = "Named guests and their devices' Tailscale IPv4 and IPv6 addresses.";
    };

    sharedHosts = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      default = {};
      example = {"vault.example.com" = ["friend"];};
      description = "Guest names allowed on each nginx website in addition to private clients. Other websites stay private.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.privateClients != [];
        message = "Set myHomelab.webAccess.privateClients before enabling website restrictions.";
      }
      {
        assertion = lib.all (name: builtins.hasAttr name cfg.guests) guestNames;
        message = "Every webAccess.sharedHosts guest must be defined in webAccess.guests.";
      }
      {
        assertion = lib.all (host: (config.services.nginx.virtualHosts.${host}.locations or {}) != {}) (lib.attrNames cfg.sharedHosts);
        message = "Every webAccess.sharedHosts entry must name a configured nginx website with locations.";
      }
    ];

    services.nginx = {
      commonHttpConfig = accessRules privateClients;
      virtualHosts =
        lib.mapAttrs (_: names: {
          extraConfig = accessRules (privateClients ++ lib.concatMap (name: cfg.guests.${name} or []) names);
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
