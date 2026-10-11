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
    services.vaultwarden = {
      enable = true;
      config = {
        DOMAIN = cfg.vaultwarden.domain;
        ROCKET_ADDRESS = "0.0.0.0";
        ROCKET_PORT = cfg.vaultwarden.port;
        WEB_VAULT_ENABLED = true;
        SIGNUPS_ALLOWED = false; # Set to true initially to create admin account, then disable
      };
    };
  };
}
