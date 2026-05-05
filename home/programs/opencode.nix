{
  programs.opencode = {
    enable = true;

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
}
