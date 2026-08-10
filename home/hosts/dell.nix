{pkgs, ...}: {
  imports = [../common ../programs ../desktops/qtile];

  myPrograms = {
    alacritty.enable = true;
    betterlockscreen.enable = true;
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
    pasystray
    pcmanfm
    papirus-icon-theme
  ];
}
