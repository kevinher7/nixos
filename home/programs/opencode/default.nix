{
  pkgs,
  username,
  profile,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    prettier
    shfmt
  ];

  programs.opencode = {
    enable = true;

    commands = {
      lint = ./commands/lint.md;
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
        "4096"
      ];
      # TODO: add environmentFile with sops-nix password
      # environmentFile = "/run/secrets/opencode-web";
    };
  };

  systemd.user.services.opencode-web = lib.mkIf (profile == "server") {
    Service = {
      WorkingDirectory = "/home/${username}/nixos-config";
      Environment = "PATH=/run/current-system/sw/bin:/etc/profiles/per-user/${username}/bin:/home/${username}/.nix-profile/bin:/usr/bin:/bin";
    };
  };
}
