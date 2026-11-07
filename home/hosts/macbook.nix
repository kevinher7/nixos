{pkgs, ...}: {
  imports = [../common ../programs];

  home.packages = [pkgs.postgresql];

  programs.tmux.enable = true;

  myPrograms = {
    aerospace.enable = true;
    dbeaver.enable = true;
    ghostty.enable = true;
    nixvim.enable = true;
    agents = {
      claude-code = {
        enable = true;
        accounts = {
          default.home = ".claude";
        };
      };
      codex = {
        enable = true;
        accounts = {
          default.home = ".codex";
          nikola.home = ".codex-nikola";
        };
      };
      opencode.enable = true;
      pi = {
        enable = true;
        accounts = {
          default.home = ".pi/agent";
        };
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
