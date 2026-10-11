{
  lib,
  config,
  ...
}: {
  programs.rofi = {
    enable = true;

    settings = {
      terminal = "${lib.getExe config.programs.alacritty.package}";
      modes = ["drun"];
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
