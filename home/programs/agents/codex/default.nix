{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
  cfg = config.myPrograms.agents;
in {
  options.myPrograms.agents.codex.accounts = import ../accounts.nix {inherit lib;};

  config = lib.mkIf cfg.codex.enable {
    myPrograms.agents.codex.accounts.default.home = lib.mkDefault ".codex";

    home.packages = [pkgs.jq];

    home.file =
      {
        ".codex/hooks/format-on-stop.sh".source = ./hooks/format-on-stop.sh;
      }
      // lib.mapAttrs' (_: account:
        lib.nameValuePair "${account.home}/AGENTS.md" {
          source = ../CONTEXT.md;
        })
      (lib.filterAttrs (_: account: account.home != ".codex") cfg.codex.accounts);

    programs.codex = {
      enable = true;
      package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;
      context = ../CONTEXT.md;
      skills = "${inputs.agent-toolkit}/skills";
      mutableSettings = true;

      settings = {
        model = "gpt-6.1-sol";
        model_reasoning_effort = "medium";
        plan_mode_reasoning_effort = "high";
        personality = "pragmatic";
        approval_policy = "never";
        sandbox_mode = "danger-full-access";

        features = {
          multi_agent = true;
          hooks = true;
        };

        projects."${config.home.homeDirectory}/nixos-config".trust_level = "trusted";
      };

      hooks = {
        Stop = [
          {
            hooks = [
              {
                type = "command";
                command = "${lib.getExe pkgs.bash} ${lib.escapeShellArg "${config.home.homeDirectory}/.codex/hooks/format-on-stop.sh"}";
                statusMessage = "Running auto-format hook";
                timeout = 120;
              }
            ];
          }
        ];
      };
    };
  };
}
