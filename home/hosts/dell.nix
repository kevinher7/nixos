{pkgs, ...}: {
  imports = [../common ../programs ../desktops/sway];

  myPrograms = {
    alacritty.enable = true;
    kanshi.enable = true;
    qutebrowser.enable = true;
    rquickshare.enable = true;
    nixvim.enable = true;
    opencode.enable = true;
    zen-browser.enable = true;
  };

  services.kanshi.settings = [
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
