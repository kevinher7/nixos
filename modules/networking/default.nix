{
  config,
  lib,
  ...
}: let
  cfg = config.myModules;
in {
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

      operatorUser = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          User allowed to run tailscale commands without sudo. This grants
          control over the whole node, not only over Serve mappings.
        '';
        example = "kevin";
      };
    };
  };

  config = lib.mkIf cfg.networking.enable {
    networking = {
      hostName = cfg.networking.hostname;
      networkmanager.enable = true;

      firewall = {
        enable = true;
        allowedUDPPorts = [5353];

        trustedInterfaces = ["tailscale0"];
      };
    };

    services = {
      tailscale = lib.mkIf cfg.networking.tailscale.enable {
        enable = true;
        inherit (cfg.networking.tailscale) openFirewall;
        extraSetFlags =
          lib.optional cfg.networking.tailscale.ssh "--ssh"
          ++ lib.optional (cfg.networking.tailscale.operatorUser != null) "--operator=${cfg.networking.tailscale.operatorUser}";
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
