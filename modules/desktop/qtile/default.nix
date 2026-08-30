{pkgs, ...}: let
  fixQtileSessions = qtile:
    pkgs.symlinkJoin {
      name = "${qtile.name}-fixed-sessions";
      paths = [qtile];

      postBuild = ''
        for sessionDirectory in xsessions wayland-sessions; do
          genericSession="$out/share/$sessionDirectory/qtile-generic.desktop"
          qtileSession="$out/share/$sessionDirectory/qtile.desktop"

          if [ -e "$genericSession" ]; then
            rm -f "$qtileSession"
            mv "$genericSession" "$qtileSession"
          fi
        done
      '';

      passthru = {
        inherit (qtile) pythonModule;
        providedSessions = ["qtile"];
        override = args: fixQtileSessions (qtile.override args);
      };

      inherit (qtile) meta;
    };
in {
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
      package = fixQtileSessions pkgs.python3Packages.qtile;
    };
    libinput.touchpad.naturalScrolling = true;
  };

  # qtile's gdk-pixbuf has no SVG loader in scope, so StatusNotifier tray
  # icons (which apps send as SVG) fail to decode and render as black boxes.
  # librsvg's loaders.cache lists every loader (base formats + SVG).
  environment.sessionVariables.GDK_PIXBUF_MODULE_FILE = "${pkgs.librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
}
