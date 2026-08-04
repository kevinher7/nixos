{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}: {
  programs.rofi = {
    enable = true;

    package =
      if osConfig.programs.hyprland.enable
      then pkgs.rofi-wayland
      else pkgs.rofi;

    terminal = "${lib.getExe config.programs.alacritty.package}";

    modes = [
      "drun"
    ];

    extraConfig = {
      icon-theme = "Papirus";
      show-icons = true;
      drun-display-format = "{icon} {name}";
      location = 0;
      disable-history = false;
      hide-scrollbar = true;
      display-drun = "   Apps ";
      sidebar-mode = true;
    };
  };
}
