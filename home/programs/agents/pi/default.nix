{
  config,
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = config.myPrograms.agents.pi;
  extensions = pkgs.callPackage ./extensions/package.nix {};
  rtk = pkgs.callPackage ../rtk-oss.nix {};
in {
  config = lib.mkIf cfg.enable {
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
        extensions = [
          "${extensions}/share/pi-extensions/format.js"
          "${extensions}/share/pi-extensions/rtk.js"
        ];
        skills = ["${inputs.agent-toolkit}/skills"];
      };

      models.providers = lib.mkIf cfg.useOpenrouter {
        openrouter.apiKey = "!cat ${osConfig.sops.secrets.openrouter_api_key.path}";
      };
    };
  };
}
