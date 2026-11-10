{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.myPrograms.agents;
in {
  imports = [
    ./claude-code.nix
    ./codex.nix
    ./opencode.nix
    ./pi
  ];

  myPrograms.agents = {
    context = lib.mkDefault ./CONTEXT.md;
    skills = lib.mkDefault "${inputs.agent-toolkit}/skills";
  };

  assertions = [
    {
      assertion = !cfg.work-toolkit.enable || cfg.claude-code.enable;
      message = "The work plugin requires myPrograms.agents.claude-code.enable.";
    }
  ];
}
