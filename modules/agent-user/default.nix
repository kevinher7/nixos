{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.agentUser;
  sshKeys = import ../networking/ssh-keys.nix;
in {
  options.myModules.agentUser = {
    enable = lib.mkEnableOption "unprivileged account that runs the coding agents and the T3 Code server";

    name = lib.mkOption {
      type = lib.types.str;
      default = "agent";
      description = "Name of the agent account.";
    };

    authorizedClients = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (builtins.attrNames sshKeys));
      default = [];
      description = "Hosts from ssh-keys.nix whose key may log in as the agent account.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.name} = {
      isNormalUser = true;
      extraGroups = ["systemd-journal"];
      shell = pkgs.bash;
      openssh.authorizedKeys.keys = map (client: sshKeys.${client}) cfg.authorizedClients;
    };

    home-manager.users.${cfg.name} = import ../../home/users/agent.nix;
  };
}
