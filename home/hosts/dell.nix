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
