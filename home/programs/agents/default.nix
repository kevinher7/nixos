{config, ...}: let
  cfg = config.myPrograms.agents;
in {
  imports = [
    ./claude-code.nix
    ./codex.nix
    ./opencode.nix
    ./pi.nix
  ];

  assertions = [
    {
      assertion = !cfg.work-toolkit.enable || cfg.claude-code.enable;
      message = "The work plugin requires myPrograms.agents.claude-code.enable.";
    }
  ];
}
