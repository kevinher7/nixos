{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
  cfg = config.myPrograms.agents;
in {
  programs.codex = lib.mkIf cfg.codex.enable {
    enable = true;
    package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;
    context = ./CONTEXT.md;
    # Preserve local MCP/plugin/project settings until the attended cutover.
    settings = null;
    skills = lib.mkIf (cfg.toolkitSource != null) "${cfg.toolkitSource}/skills";
  };
}
