{
  lib,
  config,
  ...
}: {
  programs.rofi = {
    enable = true;

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
