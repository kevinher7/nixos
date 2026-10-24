{
  config,
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = config.myPrograms.agents.pi;
in {
  config = lib.mkIf cfg.enable {
    programs.pi-coding-agent = {
      enable = true;
      package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi;
      context = ./CONTEXT.md;

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

    home.file.".pi/agent/skills".source = "${inputs.agent-toolkit}/skills";
  };
}
