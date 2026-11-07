{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
  cfg = config.myPrograms.agents;
  claudeDir = "${config.home.homeDirectory}/.claude";
  agentPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  rtk = pkgs.callPackage ./rtk-oss.nix {};
in {
  options.myPrograms.agents.claude-code.accounts = import ./accounts.nix {inherit lib;};

  config = lib.mkIf cfg.claude-code.enable {
    myPrograms.agents.claude-code.accounts.default.home = lib.mkDefault ".claude";

    home.packages = [pkgs.jq rtk];

    home.file =
      {
        ".claude/RTK.md".source = ./RTK.md;
        ".claude/statusline-context.sh".source = ./statusline-context.sh;
      }
      // lib.mergeAttrsList (lib.mapAttrsToList (_: account: {
          "${account.home}/CLAUDE.md".text = config.programs.claude-code.context;
          "${account.home}/RTK.md".source = ./RTK.md;
        })
        (lib.filterAttrs (_: account: account.home != ".claude") cfg.claude-code.accounts));

    programs.claude-code = {
      enable = true;
      package = agentPkgs.claude-code;
      context = builtins.readFile ./CONTEXT.md + "\n@RTK.md\n";
      hooksDir = ./hooks;
      skills = "${inputs.agent-toolkit}/skills";
      commandsDir = "${inputs.agent-toolkit}/commands";
      plugins = lib.mkIf cfg.work-toolkit.enable {
        work = "${inputs.agent-toolkit}/plugins/work";
      };

      settings = {
        env = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          CLAUDE_CODE_CERT_STORE = "bundled";
        };
        permissions = {
          allow = [
            "Bash(poetry run ruff check *)"
            "Bash(poetry run ruff check --fix *)"
            "Bash(npx tsc --noEmit*)"
            "Bash(poetry run ty check *)"
          ];
          deny = [
            "EnterPlanMode"
            "ExitPlanMode"
            "DesignSync"
            "NotebookEdit"
            "SendMessage"
            "PushNotification"
            "RemoteTrigger"
            "ReportFindings"
            "ScheduleWakeup"
            "AskUserQuestion"
            "CronCreate"
            "CronDelete"
            "CronList"
            "Read(**/.env)"
            "Read(**/.envrc)"
            "Read(**/*.pem)"
            "Read(**/*.key)"
            "Read(**/id_rsa)"
            "Read(**/id_ed25519)"
            "Read(**/.ssh/id_*)"
            "Read(**/.aws/credentials)"
            "Read(**/credentials.json)"
          ];
        };
        model = "opus[1m]";
        disableClaudeAiConnectors = true;
        disableBundledSkills = true;
        disableRemoteControl = true;
        disableWorkflows = true;
        disableArtifact = true;
        effortLevel = "high";
        tui = "fullscreen";
        autoMemoryEnabled = false;
        skipDangerousModePermissionPrompt = true;
        theme = "light-daltonized";
        statusLine = {
          type = "command";
          command = "${lib.getExe pkgs.bash} ${lib.escapeShellArg "${claudeDir}/statusline-context.sh"}";
        };
        hooks = {
          PostToolUse = [
            {
              matcher = "Write|Edit";
              hooks = [
                {
                  type = "command";
                  command = "${lib.getExe pkgs.python3} ${lib.escapeShellArg "${claudeDir}/hooks/format-on-save.py"}";
                }
              ];
            }
          ];
          PreToolUse = [
            {
              matcher = "Bash";
              hooks = [
                {
                  type = "command";
                  command = "${lib.getExe rtk} hook claude";
                }
              ];
            }
          ];
        };
      };
    };
  };
}
