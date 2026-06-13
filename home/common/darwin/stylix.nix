{
  lib,
  inputs,
  ...
}: let
  wallpaper = ../../../assets/wallpapers/bunny.png;
in {
  # The Stylix nix-darwin module installs fonts system-wide but does not wire up
  # the Home Manager options on darwin, so import the HM module explicitly here.
  imports = [inputs.stylix.homeModules.stylix];

  stylix = {
    enable = true;

    # Home Manager runs as a nix-darwin module here; the version-skew check
    # between Stylix and nix-darwin is noisy and not actionable, so disable it.
    enableReleaseChecks = false;

    # We import the HM module manually rather than via system-level auto-import,
    # so Stylix's own "disable overlays under useGlobalPkgs" guard never fires.
    overlays.enable = false;

    image = wallpaper;
    polarity = "dark";

    targets = {
      ghostty.enable = true;
      tmux.enable = true;
      starship.enable = false;

      btop.enable = true;

      zen-browser.enable = false;

      nixvim.enable = false;
      opencode.enable = false;
    };
  };

  home.activation.setWallpaper = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run /usr/bin/osascript -e \
      'tell application "System Events" to tell every desktop to set picture to "${toString wallpaper}"'
  '';
}
