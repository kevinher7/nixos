{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
  cfg = config.myPrograms.agents;
  agentPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  rtk = pkgs.callPackage ../rtk-oss.nix {};
in {
  config = lib.mkIf cfg.claude-code.enable {
    home.packages = [pkgs.jq rtk];

    programs.claude-code = {
      enable = true;
      mutableSettings = true;
      package = agentPkgs.claude-code;
      context = builtins.readFile ../CONTEXT.md + "\n" + builtins.readFile ./RTK.md;
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
          command = "${lib.getExe pkgs.bash} ${./statusline-context.sh}";
        };
        hooks = {
          PostToolUse = [
            {
              matcher = "Write|Edit";
              hooks = [
                {
                  type = "command";
                  command = "${lib.getExe pkgs.python3} ${./hooks/format-on-save.py}";
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
