{
  config,
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = config.myPrograms.agents;
in {
  config = lib.mkIf cfg.pi.enable {
    programs.pi-coding-agent = {
      enable = true;
      package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi;
      context = ./CONTEXT.md;
      models.providers.openrouter.apiKey = "!cat ${osConfig.sops.secrets.openrouter_api_key.path}";
    };

    home.file.".pi/agent/skills".source = "${inputs.agent-toolkit}/skills";
  };
}
