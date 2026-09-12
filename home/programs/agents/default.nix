{
  config,
  lib,
  profile,
  osFamily,
  ...
}: let
  cfg = config.myPrograms.agents;
in {
  imports = [
    ./claude-code.nix
    ./codex.nix
    ./opencode.nix
  ];

  assertions = [
    {
      assertion = !cfg.claude-code.enable || (osFamily == "darwin" && profile == "macbook");
      message = "Claude Code is supported only on the macbook profile.";
    }
    {
      assertion = !cfg.work-toolkit.enable || cfg.claude-code.enable;
      message = "The work plugin requires myPrograms.agents.claude-code.enable.";
    }
  ];
}
