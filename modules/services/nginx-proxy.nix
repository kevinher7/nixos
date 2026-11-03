{
  config,
  lib,
  ...
}: let
  cfg = config.myHomelab;
  vars = config.myVars;
  inherit (vars) domain;
  vaultDomain = "vault.${domain}";
  piholeDomain = "pihole.${domain}";
  groupType = lib.types.enum (import ../devices/groups.nix);
  groupAddresses = groups:
    lib.unique (lib.concatMap (device: device.addresses)
      (lib.filter (device: lib.any (group: builtins.elem group device.groups) groups)
        (builtins.attrValues config.myDevices.devices)));
  privateClients = ["127.0.0.1" "::1"] ++ groupAddresses cfg.webAccess.privateGroups;
  accessRules = clients:
    lib.concatMapStrings (address: "allow ${address};\n") clients + "deny all;\n";
in {
  options.myHomelab = {
    nginxProxy.enable = lib.mkEnableOption "Nginx reverse proxy with automatic HTTPS";

    webAccess = {
      enable = lib.mkEnableOption "private-by-default nginx websites with explicit guest access";

      privateGroups = lib.mkOption {
        type = lib.types.listOf groupType;
        default = [];
        description = "Device groups allowed on every website. Loopback is always allowed.";
      };

      sharedHosts = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options.groups = lib.mkOption {
            type = lib.types.listOf groupType;
            default = [];
            description = "Device groups allowed on this website in addition to private groups.";
          };
        });
        default = {};
        description = "Websites with explicit guest access. Other websites stay private.";
      };
    };
  };

  config = lib.mkIf cfg.nginxProxy.enable {
    sops.secrets.cloudflare_dns_api_token = {
      owner = "acme";
      group = "acme";
      mode = "0400";
    };

    sops.templates."acme-cloudflare.env" = {
      owner = "acme";
      group = "acme";
      mode = "0400";
      content = ''
        CF_DNS_API_TOKEN=${config.sops.placeholder.cloudflare_dns_api_token}
      '';
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = vars.acmeEmail;
      certs.${domain} = {
        inherit domain;
        extraDomainNames =
          [
            vaultDomain
            piholeDomain
          ]
          ++ lib.optionals cfg.actual.enable [cfg.actual.domain]
          ++ lib.optionals cfg.actualHttpApi.enable [cfg.actualHttpApi.domain]
          ++ lib.optionals cfg.harmonia.enable [cfg.harmonia.domain];
        dnsProvider = "cloudflare";
        environmentFile = config.sops.templates."acme-cloudflare.env".path;
      };
    };

    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      commonHttpConfig = lib.mkIf cfg.webAccess.enable (accessRules privateClients);

      virtualHosts = lib.mkMerge [
        {
          ${vaultDomain} = {
            forceSSL = true;
            useACMEHost = domain;
            locations."/" = {
              proxyPass = "http://127.0.0.1:${toString cfg.vaultwarden.port}";
              proxyWebsockets = true;
            };
            locations."^~ /admin" = lib.mkIf (cfg.vaultwarden.enable && cfg.webAccess.enable) {
              proxyPass = "http://127.0.0.1:${toString cfg.vaultwarden.port}";
              extraConfig = accessRules privateClients;
            };
          };

          ${piholeDomain} = {
            forceSSL = true;
            useACMEHost = domain;
            locations."/" = {
              proxyPass = "http://127.0.0.1:${cfg.pihole.webPort}/";
            };
          };
        }
        (lib.mkIf cfg.webAccess.enable (
          lib.mapAttrs (_: access: {
            extraConfig = accessRules (lib.unique (privateClients ++ groupAddresses access.groups));
          })
          cfg.webAccess.sharedHosts
          // {
            "_" = {
              default = true;
              rejectSSL = true;
              locations."/".return = "444";
            };
          }
        ))
      ];
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [80 443];

    users.users.nginx.extraGroups = ["acme"];

    systemd.services.nginx.after = ["acme-${domain}.service"];
    systemd.services.nginx.wants = ["acme-${domain}.service"];
  };
}
