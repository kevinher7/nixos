{
  config,
  lib,
  ...
}: let
  cfg = config.myPrograms.agents;
  accountsOption = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options.home = lib.mkOption {
        type = lib.types.addCheck lib.types.str (home:
          home
          != ""
          && lib.all (part: part != "" && part != "." && part != "..") (lib.splitString "/" home));
        description = "Home-relative directory for an independent account, excluding T3 shadow homes.";
      };
    });
    default = {};
    description = "Accounts receiving shared global instructions.";
  };
in {
  imports = [
    ./claude-code
    ./codex
    ./opencode.nix
    ./pi
  ];

  options.myPrograms.agents = {
    claude-code.accounts = accountsOption;
    codex.accounts = accountsOption;
    pi.accounts = accountsOption;
  };

  config.assertions = [
    {
      assertion = !cfg.work-toolkit.enable || cfg.claude-code.enable;
      message = "The work plugin requires myPrograms.agents.claude-code.enable.";
    }
  ];
}
