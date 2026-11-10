{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
  cfg = config.myPrograms.agents;
  sharedSettings = {
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
  };
  settingsFile = (pkgs.formats.toml {}).generate "codex-shared-settings.toml" sharedSettings;
in {
  config = lib.mkIf cfg.codex.enable {
    home.packages = [pkgs.jq];

    home.file =
      {
        ".codex/hooks/format-on-stop.sh".source = ./codex-hooks/format-on-stop.sh;
      }
      // lib.mergeAttrsList (map (home: {
          "${home}/config.toml".source = settingsFile;
          "${home}/AGENTS.md".source = config.home.file.".codex/AGENTS.md".source;
          "${home}/hooks.json".source = config.home.file.".codex/hooks.json".source;
          "${home}/hooks/format-on-stop.sh".source = ./codex-hooks/format-on-stop.sh;
          "${home}/skills" = {
            inherit (config.home.file.".codex/skills") source recursive ignorelinks;
          };
        })
        cfg.codex.additionalHomes);

    programs.codex = {
      enable = true;
      package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;
      inherit (cfg) context;
      inherit (cfg) skills;
      mutableSettings = false;

      settings =
        sharedSettings
        // {
          projects."${config.home.homeDirectory}/nixos-config".trust_level = "trusted";
        };

      hooks = {
        Stop = [
          {
            hooks = [
              {
                type = "command";
                command = "${lib.getExe pkgs.bash} ${lib.escapeShellArg (toString ./codex-hooks/format-on-stop.sh)}";
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
