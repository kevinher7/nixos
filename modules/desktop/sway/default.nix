{pkgs, ...}: {
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    xwayland.enable = true;

    extraPackages = with pkgs; [
      brightnessctl
      grim
      slurp
      swayidle
      swaylock
      wl-clipboard
    ];
  };
}
