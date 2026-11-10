{
  config,
  inputs,
  pkgs,
  lib,
  setupAccount,
  ...
}: let
  cfg = config.myPrograms.agents;
  agentPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  rtk = pkgs.callPackage ../rtk-oss.nix {};
  pluginHelpers = (import "${inputs.home-manager}/modules/programs/claude-code/lib.nix" {inherit lib pkgs;}).mkHelpers {
    configDir = config.programs.claude-code.configDir;
  };
  shared = {
    agent = "claude";
    files =
      {
        "CLAUDE.md".text = config.programs.claude-code.context;
        "RTK.md".source = ./RTK.md;
        "statusline-context.sh".source = ./statusline-context.sh;
        hooks = {
          source = ./hooks;
          recursive = true;
        };
        skills = {
          source = config.programs.claude-code.skills;
          recursive = true;
        };
        commands = {
          source = config.programs.claude-code.commandsDir;
          recursive = true;
        };
      }
      // lib.mapAttrs' (name: plugin:
        lib.nameValuePair "skills/${name}" {
          inherit (pluginHelpers.mkPluginEntry name plugin) source;
        })
      config.programs.claude-code.plugins;
    settings = {
      file = "settings.json";
      format = "json";
      value = config.programs.claude-code.settings;
      jqOperation = ''if ($dynamic | type) == "object" and ($static | type) == "object" then $dynamic * $static else error("expected JSON objects") end'';
    };
  };
in {
  config = lib.mkIf cfg.claude-code.enable {
    myPrograms.agents.claude-code.accounts.default.home = lib.mkDefault ".claude";

    home = lib.mkMerge (
      [
        {
          packages = [pkgs.jq rtk];
          file = {
            ".claude/RTK.md".source = ./RTK.md;
            ".claude/statusline-context.sh".source = ./statusline-context.sh;
          };
        }
      ]
      ++ lib.mapAttrsToList
      (name: account: setupAccount name account shared)
      (builtins.removeAttrs cfg.claude-code.accounts ["default"])
    );

    programs.claude-code = {
      enable = true;
      mutableSettings = true;
      package = agentPkgs.claude-code;
      context = builtins.readFile ../CONTEXT.md + "\n@RTK.md\n";
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
