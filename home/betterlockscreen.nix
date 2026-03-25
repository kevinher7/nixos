{ config, lib, pkgs, ... }:
let
  lockImage = ../walls/girl-reading-book.png;
  lockImageTarget = "${config.home.homeDirectory}/.config/betterlockscreen/lock.png";

  lockWrapper = pkgs.writeShellScriptBin "lock-with-betterlockscreen" ''
    set -euo pipefail

    cache_root="$XDG_CACHE_HOME"

    if [ -z "$cache_root" ]; then
      cache_root="$HOME/.cache"
    fi

    cache_dir="$cache_root/betterlockscreen"
    stamp="$cache_dir/.layout-stamp"

    layout="$(${pkgs.xorg.xrandr}/bin/xrandr --current | \
      ${pkgs.gnugrep}/bin/grep -E ' connected|current ' || true)"

    new="$(${pkgs.coreutils}/bin/printf '%s' "$layout" | \
      ${pkgs.coreutils}/bin/sha256sum | \
      ${pkgs.coreutils}/bin/cut -d' ' -f1)"

    old=""
    if [ -f "$stamp" ]; then
      old="$(cat "$stamp" || true)"
    fi

    if [ "$new" != "$old" ] || [ ! -d "$cache_dir/current" ]; then
      mkdir -p "$cache_dir"

      ${pkgs.betterlockscreen}/bin/betterlockscreen -u ${
        lib.escapeShellArg lockImageTarget
      }

      echo "$new" > "$stamp"
    fi

    exec ${pkgs.betterlockscreen}/bin/betterlockscreen -l dimblur
  '';

in
{
  home.packages = with pkgs; [
    betterlockscreen
    xss-lock
  ];

  xdg.configFile."betterlockscreen/lock.png".source = lockImage;

  services.screen-locker = {
    enable = true;
    lockCmd = lib.mkForce "${lockWrapper}/bin/lock-with-betterlockscreen";
    inactiveInterval = lib.mkForce 3;
  };
}
