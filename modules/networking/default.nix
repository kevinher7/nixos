{
  config,
  lib,
  username,
  ...
}: let
  cfg = config.myModules;
  sshKeys = import ./ssh-keys.nix;
in {
  options.myModules.networking = {
    enable = lib.mkEnableOption "Networking Configuration";

    hostname = lib.mkOption {
      type = lib.types.str;
      description = "The hostname of the machine";
    };

    ssh.authorizedClients = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (builtins.attrNames sshKeys));
      description = "Hosts from ssh-keys.nix whose key may log in as the main user";
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
    users.users.${username}.openssh.authorizedKeys.keys =
      map (client: sshKeys.${client}) cfg.networking.ssh.authorizedClients;

    networking = {
      hostName = cfg.networking.hostname;
      networkmanager.enable = true;

      firewall = {
        enable = true;
        allowedUDPPorts = [5353];

        interfaces.tailscale0.allowedTCPPorts = [22];
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

      openssh = {
        enable = true;
        openFirewall = false;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
        };
      };

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
