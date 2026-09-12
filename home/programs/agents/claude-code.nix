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
in {
  config = lib.mkIf cfg.claude-code.enable {
    home.packages = [pkgs.jq pkgs.rtk];

    home.file = {
      ".claude/RTK.md".source = ./RTK.md;
      ".claude/statusline-context.sh".source = ./statusline-context.sh;
    };

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
                  command = "${lib.getExe pkgs.rtk} hook claude";
                }
              ];
            }
          ];
        };
      };
    };
  };
}
