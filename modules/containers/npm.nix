{ config, pkgs, lib, ... }:
let
  cfg = config.myHomelab;
in
{
  options.myHomelab.npm = {
    enable = lib.mkEnableOption "Nginx Proxy Manager";
  };

  config = lib.mkIf cfg.npm.enable {
    virtualisation.oci-containers.containers.npm = {
      image = "jc21/nginx-proxy-manager:latest";
      autoStart = true;
      ports = [
        "80:80"
        "81:81"
        "443:443"
      ];

      volumes = [
        "/var/lib/npm/data:/data"
        "/var/lib/npm/letsencrypt:/etc/letsencrypt"
      ];
    };

    systemd = {
      tmpfiles.rules = [
        "d /var/lib/npm/data 0750 root root -"
        "d /var/lib/npm/letsencrypt 0750 root root -"
      ];

      services."podman-network-homelab" = {
        path = [ pkgs.podman ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.podman}/bin/podman network create homelab";
          ExecStop = "${pkgs.podman}/bin/podman network rm homelab";
        };
      };
    };
  };
}

