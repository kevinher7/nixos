{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.myPrograms.openvpn;

  # Split-tunnel OpenVPN wrapper: creds + profile from 1Password, tunnel runs as
  # a backgrounded root daemon. Each command is a standalone, shellcheck-linted
  # binary. Only `dig` is pinned via runtimeInputs; `op` (desktop-authorized CLI)
  # and `sudo openvpn` (secure_path) are deliberately left to the ambient PATH.
  mkCmd = name:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [pkgs.dnsutils];
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
