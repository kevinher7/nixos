{ lib, ... }:
{
  imports = [
    ./npm.nix
    ./vaultwarden.nix
  ];

  options.myHomelab = {
    vaultwarden = {
      enable = lib.mkEnableOption "Vaultwarden password manager";
      domain = lib.mkOption {
        type = lib.types.str;
      };
    };

    npm = {
      enable = lib.mkEnableOption "Nginx Proxy Manager";
    };
  };
}

