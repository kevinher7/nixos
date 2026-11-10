{
  config,
  inputs,
  pkgs,
  lib,
  setupAccount,
  ...
}: let
  cfg = config.myPrograms.agents;
  rtk = pkgs.callPackage ../rtk-oss.nix {};
  shared = {
    agent = "codex";
    files = {
      "AGENTS.md".source = config.programs.codex.context;
      "hooks.json".source = (pkgs.formats.json {}).generate "codex-account-hooks" {
        hooks = config.programs.codex.hooks;
      };
      "hooks/format-on-stop.sh".source = ./hooks/format-on-stop.sh;
      skills = {
        source = config.programs.codex.skills;
        recursive = true;
      };
    };
    settings = {
      file = "config.toml";
      format = "toml";
      value = config.programs.codex.settings;
      jqOperation = ''
        ($dynamic * $static)
        | reduce (($static.mcp_servers // {}) | to_entries[]) as $server (.;
            if $server.value | has("url") then
              .mcp_servers[$server.key] |= del(.command, .args, .env, .env_vars, .cwd)
            elif $server.value | has("command") then
              .mcp_servers[$server.key] |= del(.url, .bearer_token, .bearer_token_env_var, .http_headers, .env_http_headers, .http_headers_helper, .oauth, .oauth_resource, .auth)
            else . end)
      '';
    };
  };
in {
  config = lib.mkIf cfg.codex.enable {
    myPrograms.agents.codex.accounts.default.home = lib.mkDefault ".codex";

    home = lib.mkMerge (
      [
        {
          packages = [pkgs.jq rtk];
          file.".codex/hooks/format-on-stop.sh".source = ./hooks/format-on-stop.sh;
        }
      ]
      ++ lib.mapAttrsToList
      (name: account: setupAccount name account shared)
      (builtins.removeAttrs cfg.codex.accounts ["default"])
    );

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
        PreToolUse = [
          {
            matcher = "Bash";
            hooks = [
              {
                type = "command";
                command = "${lib.getExe rtk} hook codex";
              }
            ];
          }
        ];
        Stop = [
          {
            hooks = [
              {
                type = "command";
                command = "${lib.getExe pkgs.bash} ${./hooks/format-on-stop.sh}";
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
