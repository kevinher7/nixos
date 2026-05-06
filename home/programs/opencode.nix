{username, ...}: {
  programs.opencode = {
    enable = true;

    settings = {
      permission = {
        "*" = "allow";
        "doom_loop" = "allow";
        "external_directory" = "allow";
      };
    };

    web = {
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

  systemd.user.services.opencode-web.Service = {
    WorkingDirectory = "/home/${username}/nixos-config";
    Environment = "PATH=/run/current-system/sw/bin:/home/${username}/.nix-profile/bin:/usr/bin:/bin";
  };
}
