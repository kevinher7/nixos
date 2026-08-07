{pkgs, ...}: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # `programs.hyprland` already pulls in xdg-desktop-portal-hyprland; the GTK
  # portal is what gives file pickers to apps that ask for one.
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  # Unlocking from hyprlock goes through PAM.
  security.pam.services.hyprlock.enable = true;

  # No services.libinput here: it only emits an xorg.conf.d snippet, and its
  # `enable` default follows services.xserver.enable, which is off on this
  # host. Touchpad settings live in the Hyprland `input.touchpad` block.
  environment.systemPackages = with pkgs; [
    brightnessctl # Wayland replacement for `light`
    wl-clipboard
  ];
}
