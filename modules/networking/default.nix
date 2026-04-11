{ config, lib, ... }:
let
  cfg = config.myModules;
in
{
  options.myModules.networking = {
    enable = lib.mkEnableOption "Networking Configuration";

    hostname = lib.mkOption {
      type = lib.types.str;
      description = "The hostname of the machine";
    };

    tailscale = {
      enable = lib.mkEnableOption "Tailscale VPN";

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open firewall for Tailscale (UDP 41641)";
      };

      ssh = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Tailscale SSH server (--ssh flag)";
      };
    };
  };

  config = lib.mkIf cfg.networking.enable {
    networking.hostName = cfg.networking.hostname;
    networking.networkmanager.enable = true;

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 9300 ];
      allowedUDPPorts = [ 5353 ];
    };

    services = {
      tailscale = lib.mkIf cfg.networking.tailscale.enable {
        enable = true;
        openFirewall = cfg.networking.tailscale.openFirewall;
        extraSetFlags = lib.optional cfg.networking.tailscale.ssh "--ssh";
      };

      openssh.enable = true;

      avahi = {
        enable = true;
        nssmdns4 = true;
        publish = {
          enable = true;
          userServices = true;
        };
      };
    };
  };
}
