{pkgs, ...}: {
  imports = [
    ./xserver.nix
    ./picom.nix
  ];

  services = {
    xserver.windowManager.qtile = {
      enable = true;

      # Qtile 0.37 installs qtile-generic.desktop while still declaring the
      # provided session as "qtile". Keep the session name stable until the
      # mismatch introduced by NixOS/nixpkgs#550623 is fixed upstream.
      package = pkgs.python3Packages.qtile.overrideAttrs (oldAttrs: {
        postInstall =
          oldAttrs.postInstall
          + ''
            for sessionDirectory in xsessions wayland-sessions; do
              genericSession="$out/share/$sessionDirectory/qtile-generic.desktop"
              if [ -e "$genericSession" ]; then
                mv "$genericSession" "$out/share/$sessionDirectory/qtile.desktop"
              fi
            done
          '';
      });
    };
    libinput.touchpad.naturalScrolling = true;
  };

  # qtile's gdk-pixbuf has no SVG loader in scope, so StatusNotifier tray
  # icons (which apps send as SVG) fail to decode and render as black boxes.
  # librsvg's loaders.cache lists every loader (base formats + SVG).
  environment.sessionVariables.GDK_PIXBUF_MODULE_FILE = "${pkgs.librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
}
