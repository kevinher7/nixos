{
  config,
  lib,
  ...
}: let
  cfg = config.myPrograms.agents;
in {
  imports = [
    ./claude-code
    ./codex
    ./opencode.nix
    ./pi
    (lib.mkAliasOptionModule ["myPrograms" "agents" "claude-code" "accounts"] ["programs" "claude-code" "accounts"])
    (lib.mkAliasOptionModule ["myPrograms" "agents" "codex" "accounts"] ["programs" "codex" "accounts"])
    (lib.mkAliasOptionModule ["myPrograms" "agents" "pi" "accounts"] ["programs" "pi-coding-agent" "accounts"])
  ];

  config.assertions = [
    {
      assertion = !cfg.work-toolkit.enable || cfg.claude-code.enable;
      message = "The work plugin requires myPrograms.agents.claude-code.enable.";
    }
  ];
}
