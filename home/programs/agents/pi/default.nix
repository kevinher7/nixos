{
  config,
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = config.myPrograms.agents;
  extensions = pkgs.callPackage ./extensions/package.nix {};
  rtk = pkgs.callPackage ../rtk-oss.nix {};
in {
  config = lib.mkIf cfg.pi.enable {
    programs.pi-coding-agent = {
      enable = true;
      package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi;
      context = builtins.readFile cfg.context + "\n" + builtins.readFile ./CONTEXT.md;
      extraPackages = [rtk];
      mutableSettings = false;

      settings = {
        defaultProvider = "openai";
        defaultModel = "gpt-6.1-sol";
        defaultThinkingLevel = "medium";
        collapseChangelog = true;
      };

      models.providers = lib.mkIf cfg.pi.useOpenrouter {
        openrouter.apiKey = "!cat ${osConfig.sops.secrets.openrouter_api_key.path}";
      };
    };

    home.file =
      {
        ".pi/agent/extensions/format.js".source = "${extensions}/share/pi-extensions/format.js";
        ".pi/agent/extensions/rtk.js".source = "${extensions}/share/pi-extensions/rtk.js";
        ".pi/agent/skills".source = cfg.skills;
      }
      // lib.mergeAttrsList (map (home:
        {
          "${home}/settings.json".source = config.home.file."${config.home.homeDirectory}/.pi/agent/settings.json".source;
          "${home}/AGENTS.md".source = config.home.file."${config.home.homeDirectory}/.pi/agent/AGENTS.md".source;
          "${home}/extensions/format.js".source = "${extensions}/share/pi-extensions/format.js";
          "${home}/extensions/rtk.js".source = "${extensions}/share/pi-extensions/rtk.js";
          "${home}/skills".source = cfg.skills;
        }
        // lib.optionalAttrs (config.programs.pi-coding-agent.models != {}) {
          "${home}/models.json".source = config.home.file."${config.home.homeDirectory}/.pi/agent/models.json".source;
        })
      cfg.pi.additionalHomes);
  };
}
