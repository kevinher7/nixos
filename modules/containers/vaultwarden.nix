{ config, lib, ... }:
let
  cfg = config.myHomelab;
in
{
  config = lib.mkIf cfg.vaultwarden.enable {
    virtualisation.oci-containers.containers.vaultwarden = {
      image = "vaultwarden/server:latest";
      autoStart = true;
      ports = [ "1821:80" ];
      volumes = [ "/var/lib/vaultwarden:/data" ];

      extraOptions = [ "--network=homelab" ];

      environment = {
        DOMAIN = "https://vault.uribogoat.duckdns.org";
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/vaultwarden 0750 1000 1000 -"
    ];
  };
}

