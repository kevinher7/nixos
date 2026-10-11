{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: let
  cfg = config.myPrograms.agents;
in {
  config = lib.mkIf cfg.opencode.enable {
    home.packages = with pkgs; [
      prettier
      shfmt
    ];

    programs.opencode = {
      enable = true;
      package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
      context = ./CONTEXT.md;
      skills = "${inputs.agent-toolkit}/skills";

      commands = {
        nix-lint = builtins.readFile "${inputs.agent-toolkit}/commands/nix-lint.md";
      };

      settings = {
        permission = {
          "*" = "ask";
          read = "allow";
          glob = "allow";
          grep = "allow";
          list = "allow";
          lsp = "allow";
          skill = "allow";
          todoread = "allow";
          todowrite = "allow";
          bash = {
            "*" = "ask";
            "git status*" = "allow";
            "git diff*" = "allow";
            "git log*" = "allow";
            "git show*" = "allow";
          };
        };

        formatter = {
          nixfmt = {
            command = ["alejandra" "--quiet" "$FILE"];
          };

          ruff = {
            command = ["ruff" "format" "$FILE"];
          };

          prettier = {
            command = ["prettier" "--write" "$FILE"];
          };

          shfmt = {
            command = ["shfmt" "-w" "$FILE"];
          };
        };
      };
    };
  };
}
