{
  config,
  inputs,
  lib,
  osConfig,
  pkgs,
  setupAccount,
  ...
}: let
  cfg = config.myPrograms.agents.pi;
  extensions = pkgs.callPackage ./extensions/package.nix {};
  rtk = pkgs.callPackage ../rtk-oss.nix {};
  shared = account: {
    agent = "pi";
    files = {
      "AGENTS.md".text = config.programs.pi-coding-agent.context;
      "models.json".source = (pkgs.formats.json {}).generate "pi-account-models" config.programs.pi-coding-agent.models;
      "extensions/format.js".source = "${extensions}/share/pi-extensions/format.js";
      "extensions/rtk.js".source = "${extensions}/share/pi-extensions/rtk.js";
      skills = {
        source = "${inputs.agent-toolkit}/skills";
        recursive = true;
      };
    };
    settings = {
      file = "settings.json";
      format = "json";
      value = config.programs.pi-coding-agent.settings;
      jqOperation = ''
        ${builtins.toJSON config.home.homeDirectory} as $homeDirectory
        | ${builtins.toJSON "${config.home.homeDirectory}/${account.home}"} as $configDir
        | ${builtins.readFile "${inputs.home-manager}/modules/programs/pi-coding-agent-settings-filter.jq"}
      '';
    };
  };
in {
  config = lib.mkIf cfg.enable {
    myPrograms.agents.pi.accounts.default.home = lib.mkDefault ".pi/agent";

    programs.pi-coding-agent = {
      enable = true;
      mutableSettings = true;
      package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi;
      context = builtins.readFile ../CONTEXT.md + "\n" + builtins.readFile ./CONTEXT.md;
      extraPackages = [rtk];

      settings = {
        defaultProvider = "openai";
        defaultModel = "gpt-6.1-sol";
        defaultThinkingLevel = "medium";
        collapseChangelog = true;
      };

      models.providers = lib.mkIf cfg.useOpenrouter {
        openrouter.apiKey = "!cat ${osConfig.sops.secrets.openrouter_api_key.path}";
      };
    };

    home = lib.mkMerge (
      [
        {
          file = {
            ".pi/agent/extensions/format.js".source = "${extensions}/share/pi-extensions/format.js";
            ".pi/agent/extensions/rtk.js".source = "${extensions}/share/pi-extensions/rtk.js";
            ".pi/agent/skills" = {
              source = "${inputs.agent-toolkit}/skills";
              recursive = true;
            };
          };
        }
      ]
      ++ lib.mapAttrsToList
      (name: account: setupAccount name account (shared account))
      (builtins.removeAttrs cfg.accounts ["default"])
    );
  };
}
