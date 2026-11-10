{
  config,
  lib,
  pkgs,
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
    description = "Accounts receiving shared declarative configuration and assets.";
  };
  setupAccount = name: account: shared: {
    file = lib.mapAttrs' (path: file:
      lib.nameValuePair "${account.home}/${path}" file)
    shared.files;

    activation."${shared.agent}Account-${name}" = lib.hm.dag.entryAfter ["linkGeneration"] (
      lib.hm.generators.mkImpureConfigMerger {
        inherit pkgs;
        inherit (shared.settings) format jqOperation;
        empty = "{}";
        mode = "600";
        path = "${config.home.homeDirectory}/${account.home}/${shared.settings.file}";
        staticSettings =
          (pkgs.formats.${shared.settings.format} {}).generate
          "${shared.agent}-account-settings"
          shared.settings.value;
      }
    );
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

  config._module.args = {inherit setupAccount;};

  config.assertions =
    [
      {
        assertion = !cfg.work-toolkit.enable || cfg.claude-code.enable;
        message = "The work plugin requires myPrograms.agents.claude-code.enable.";
      }
    ]
    ++ lib.mapAttrsToList (agent: agentCfg: let
      homes = map (account: account.home) (lib.attrValues agentCfg.accounts);
    in {
      assertion = !agentCfg.enable || lib.length homes == lib.length (lib.unique homes);
      message = "myPrograms.agents.${agent}.accounts must use distinct home directories.";
    }) {inherit (cfg) claude-code codex pi;};
}
