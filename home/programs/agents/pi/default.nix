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
  options.myPrograms.agents.pi.accounts = import ../accounts.nix {inherit lib;};

  config = lib.mkIf cfg.enable {
    myPrograms.agents.pi.accounts.default.home = lib.mkDefault ".pi/agent";

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

    home.file =
      {
        ".pi/agent/extensions/format.js".source = "${extensions}/share/pi-extensions/format.js";
        ".pi/agent/extensions/rtk.js".source = "${extensions}/share/pi-extensions/rtk.js";
        ".pi/agent/skills".source = "${inputs.agent-toolkit}/skills";
      }
      // lib.mapAttrs' (_: account:
        lib.nameValuePair "${account.home}/AGENTS.md" {
          text = config.programs.pi-coding-agent.context;
        })
      (lib.filterAttrs (_: account: account.home != ".pi/agent") cfg.accounts);
  };
}
