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

    home.file.".pi/agent/extensions/format.js".source = "${extensions}/share/pi-extensions/format.js";
    home.file.".pi/agent/extensions/rtk.js".source = "${extensions}/share/pi-extensions/rtk.js";

    home.file.".pi/agent/skills".source = "${inputs.agent-toolkit}/skills";
  };
}
