{
  config,
  lib,
  ...
}: let
  cfg = config.myHomelab;
in {
  options.myHomelab.vaultwarden = {
    enable = lib.mkEnableOption "Vaultwarden password manager";

    domain = lib.mkOption {
      type = lib.types.str;
      example = "https://vault.example.com";
      description = "Public domain for Vaultwarden";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 1821;
      description = "Internal port for Vaultwarden (proxy to this via NPM)";
    };
  };

  config = lib.mkIf cfg.vaultwarden.enable {
    myHomelab.supervision.units = ["vaultwarden"];

    sops.secrets.vaultwarden_admin_token = {
      restartUnits = ["vaultwarden.service"];
    };

    sops.templates."vaultwarden.env".content = ''
      ADMIN_TOKEN=${config.sops.placeholder.vaultwarden_admin_token}
    '';

    services.vaultwarden = {
      enable = true;
      environmentFile = config.sops.templates."vaultwarden.env".path;
      config = {
        DOMAIN = cfg.vaultwarden.domain;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = cfg.vaultwarden.port;
        WEB_VAULT_ENABLED = true;
        SIGNUPS_ALLOWED = false;
      };
    };
  };
}
