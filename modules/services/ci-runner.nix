{
  config,
  lib,
  ...
}: let
  cfg = config.myHomelab.ciRunner;
  tokenFile = config.sops.secrets.github_runner_token.path;
  veth = "ve-ci-runner";
  lanNetwork = "192.168.0.0/24";
  tailnetNetwork = "100.64.0.0/10";
in {
  options.myHomelab.ciRunner = {
    enable = lib.mkEnableOption "self-hosted GitHub Actions runner in a NixOS container";
  };

  config = lib.mkIf cfg.enable {
    # nixos-containers bind-mounts /nix/store and the daemon socket from the
    # host, so builds run under the host nix-daemon. The container isolates
    # only the workflow's shell steps.
    containers.ci-runner = {
      autoStart = true;
      ephemeral = true;
      privateNetwork = true;
      hostAddress = "10.233.1.1";
      localAddress = "10.233.1.2";

      bindMounts.${tokenFile} = {
        hostPath = tokenFile;
        isReadOnly = true;
      };

      config = {pkgs, ...}: {
        nix.settings.experimental-features = ["nix-command" "flakes"];

        # Pi-hole lives on the LAN this container is fenced off from.
        networking = {
          useHostResolvConf = false;
          nameservers = ["1.1.1.1"];
        };

        services.github-runners.nixos-ci = {
          enable = true;
          url = "https://github.com/kevinher7/nixos";
          inherit tokenFile;
          ephemeral = true;
          replace = true;
          extraLabels = ["nixos" "x86_64-linux"];
          extraPackages = [pkgs.git pkgs.cachix];
        };

        system.stateVersion = config.system.stateVersion;
      };
    };

    networking = {
      nat = {
        enable = true;
        internalInterfaces = [veth];
        externalInterface = config.networking.defaultGateway.interface;

        # -I, not -A: the nat module has already appended an ACCEPT for
        # veth -> enp2s0, and enp2s0 is the LAN. The chain is recreated on
        # every firewall reload, so this stays idempotent.
        extraCommands = ''
          iptables -w -I nixos-filter-forward -i ${veth} -d ${lanNetwork} -j DROP
          iptables -w -I nixos-filter-forward -i ${veth} -d ${tailnetNetwork} -j DROP
        '';
      };

      # -I so it beats the port rules that open Pi-hole DNS/DHCP on every
      # interface. Covers all host addresses, LAN and tailnet included.
      firewall.extraCommands = ''
        iptables -w -I nixos-fw -i ${veth} -j DROP
      '';
    };

    # Weight (default 100) rather than a quota: builds use idle cores but
    # yield to Pi-hole under contention. nix-daemon is limited too because
    # that is where builds run. MemoryHigh throttles it instead of
    # OOM-killing the server's own rebuilds.
    systemd.services = {
      "container@ci-runner".serviceConfig = {
        CPUWeight = 20;
        MemoryMax = "4G";
      };

      nix-daemon.serviceConfig = {
        CPUWeight = 20;
        MemoryHigh = "6G";
      };
    };
  };
}
