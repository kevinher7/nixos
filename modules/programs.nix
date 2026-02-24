{ pkgs, ... }:
{
  programs = {

    firefox.enable = true;
    light.enable = true;

    xss-lock = {
      enable = true;
      lockerCommand = "xsecurelock";
    };

    gdk-pixbuf.modulePackages = [ pkgs.librsvg ];
  };
}
