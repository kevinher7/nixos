{ config, lib, ... }:
let
  cfg = config.myHomelab;
in
{
  options.myHomelab.vaultwarden = {
    enable = lib.mkEnableOption "Vaultwarden password manager";

    domain = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.vaultwarden.enable {
    virtualisation.oci-containers.containers.vaultwarden = {
      image = "vaultwarden/server:latest";
      autoStart = true;
      ports = [ "127.0.0.1:1821:80" ];
      volumes = [ "/var/lib/vaulwarden:/data " ];

      extraOptions = [ "--network=homelab" ];
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/vaultwarden 0750 root root -"
    ];
  };
}

