{pkgs, ...}: {
  imports = [
    ./xserver.nix
    ./picom.nix
  ];

  services = {
    xserver.windowManager.qtile.enable = true;
    libinput.touchpad.naturalScrolling = true;
  };

  # qtile's gdk-pixbuf has no SVG loader in scope, so StatusNotifier tray
  # icons (which apps send as SVG) fail to decode and render as black boxes.
  # librsvg's loaders.cache lists every loader (base formats + SVG).
  environment.sessionVariables.GDK_PIXBUF_MODULE_FILE = "${pkgs.librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
}
