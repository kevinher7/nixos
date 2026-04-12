{ pkgs, ... }:
{
  programs = {
    firefox.enable = true;
    light.enable = true;

    gdk-pixbuf.modulePackages = [ pkgs.librsvg ];
  };
}
