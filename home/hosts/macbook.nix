{pkgs, ...}: {
  imports = [../common ../programs];

  home.packages = [pkgs.postgresql];

  programs.tmux.enable = true;

  myPrograms = {
    aerospace.enable = true;
    ghostty.enable = true;
    nixvim.enable = true;
    agents = {
      claude-code.enable = true;
      codex.enable = true;
      opencode.enable = true;
      pi = {
        enable = true;
        useOpenrouter = true;
      };
      work-toolkit.enable = true;
    };
    t3code = {
      cli.enable = true;
      desktop.enable = true;
    };
    skim.enable = true;
    sops.enable = true;
    zen-browser.enable = true;

    openvpn.enable = true;
  };
}
