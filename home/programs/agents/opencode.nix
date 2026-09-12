{
  pkgs,
  inputs,
  username,
  profile,
  osFamily,
  lib,
  config,
  osConfig,
  ...
}: let
  cfg = config.myPrograms.agents;
in {
  config = lib.mkIf cfg.opencode.enable (
    {
      home.packages = with pkgs; [
        prettier
        shfmt
      ];

      programs.opencode = {
        enable = true;
        package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
        context = ./CONTEXT.md;
        skills = lib.mkIf (cfg.toolkitSource != null) "${cfg.toolkitSource}/skills";

        commands = {
          lint =
            if cfg.toolkitSource == null
            then ./commands/lint.md
            else builtins.readFile "${cfg.toolkitSource}/commands/lint.md";
        };

        settings = {
          permission = {
            "*" = "allow";
            "doom_loop" = "allow";
            "external_directory" = "allow";
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

        web = lib.mkIf (profile == "server") {
          enable = true;
          extraArgs = [
            "--hostname"
            "0.0.0.0"
            "--port"
            (toString osConfig.myVars.opencodePort)
          ];
          # TODO: add environmentFile with sops-nix password
          # environmentFile = "/run/secrets/opencode-web";
        };
      };
    }
    // lib.optionalAttrs (osFamily == "linux") {
      systemd.user.services.opencode-web = lib.mkIf (profile == "server") {
        Service = {
          WorkingDirectory = "/home/${username}/nixos-config";
          Environment = "PATH=/run/current-system/sw/bin:/etc/profiles/per-user/${username}/bin:/home/${username}/.nix-profile/bin:/usr/bin:/bin";
        };
      };
    }
  );
}
