{ pkgs, ... }:
{
  stylix = {
    enable = true;
    autoEnable = true;

    image = ../assets/wallpapers/girl-reading-book.png;
    polarity = "dark";

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.jetbrains-mono;
        name = "JetBrains Mono";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      sizes = {
        applications = 12;
        desktop = 12;
        popups = 10;
      };
    };
  };
}
