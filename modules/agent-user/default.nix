{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.agentUser;
in {
  options.myModules.agentUser = {
    enable = lib.mkEnableOption "unprivileged account that runs the coding agents and the T3 Code server";

    name = lib.mkOption {
      type = lib.types.str;
      default = "agent";
      description = "Name of the agent account.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.name} = {
      isNormalUser = true;
      extraGroups = ["systemd-journal"];
      shell = pkgs.bash;
    };

    home-manager.users.${cfg.name} = import ../../home/users/agent.nix;
  };
}
