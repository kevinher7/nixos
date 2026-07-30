{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.myPrograms.openvpn;

  # Split-tunnel OpenVPN wrapper: creds + profile from 1Password, tunnel runs as
  # a backgrounded root daemon. Each command is a standalone, shellcheck-linted
  # binary. Nothing is pinned: `op` (desktop-authorized CLI), `sudo openvpn`
  # (secure_path) and `dig` all come from the ambient PATH. dig is deliberately
  # not pinned — nixpkgs' bind links jemalloc, which hangs at startup on Darwin,
  # so we use the macOS one. This module is macOS-only (home/hosts/macbook.nix).
  mkCmd = name:
    pkgs.writeShellApplication {
      inherit name;
      text = builtins.readFile (./. + "/${name}.sh");
    };
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      (mkCmd "ovpn")
      (mkCmd "ovpn-down")
      (mkCmd "ovpn-status")
    ];
  };
}
