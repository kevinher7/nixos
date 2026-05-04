_:
{
  programs.opencode = {
    enable = true;
    # tui.themes = "nord";

    web = {
      enable = true;
      extraArgs = [ "--hostname" "0.0.0.0" "--port" "4096" ];
      # TODO: add environmentFile with sops-nix password
    };
  };
}
