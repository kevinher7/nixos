{pkgs, ...}: {
  imports = [../common ../programs ../desktops/sway];

  myPrograms = {
    alacritty.enable = true;
    qutebrowser.enable = true;
    rquickshare.enable = true;
    nixvim.enable = true;
    agents = {
      codex.enable = true;
      opencode.enable = true;
    };
    t3code.cli.enable = true;
    vicinae.enable = true;
    zen-browser.enable = true;
  };

  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "docked";
        profile.outputs = [
          {
            criteria = "LG Electronics 32inch LG FHD *";
            status = "enable";
            position = "0,0";
          }
          {
            criteria = "eDP-1";
            status = "enable";
            position = "1920,0";
          }
        ];
      }
      {
        profile.name = "undocked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            position = "0,0";
          }
        ];
      }
    ];
  };

  programs.bash.initExtra = ''
    export PROMPT_COMMAND='PS1_CMD1=$(git branch --show-current 2>/dev/null)'
    export PS1='\[\e[38;5;93m\]\u\[\e[0m\]$ in \[\e[38;5;251m\]\w\[\e[0m\] [\[\e[38;5;196m\]''${PS1_CMD1}\[\e[0m\]] $ '
  '';

  xdg.configFile."wireplumber/wireplumber.conf.d/99-bluez-roles.conf".text = ''
    override.monitor.bluez.properties = {
      bluez5.roles = [ a2dp_source bap_source hfp_ag ]
    }
  '';

  home.packages = with pkgs; [
    playerctl
    pavucontrol
    pcmanfm
    papirus-icon-theme
  ];
}
