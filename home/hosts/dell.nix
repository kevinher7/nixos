{pkgs, ...}: {
  imports = [../common ../programs ../desktops/hyprland];

  myPrograms = {
    alacritty.enable = true;
    qutebrowser.enable = true;
    rquickshare.enable = true;
    nixvim.enable = true;
  };

  home.packages = with pkgs; [
    playerctl
    pavucontrol
    pcmanfm
    papirus-icon-theme

    # Wayland equivalents of the X11 tooling the qtile hosts use
    brightnessctl
    grim
    slurp
    wl-clipboard

    # home-manager's Hyprland onChange hook shells out to bare `jq` to reload
    # live instances after a rebuild; without it on PATH, binds go stale.
    jq
  ];
}
