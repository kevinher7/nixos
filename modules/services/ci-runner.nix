{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myHomelab.ciRunner;
  tokenFile = config.sops.secrets.github_runner_token.path;
  netns = "ci-runner";
  gcrootsDir = "/var/lib/ci-runner/gcroots";
  netnsPath = "/run/netns/${netns}";
  # tap devices report "state UNKNOWN" even when up, so check the flags and
  # the default route slirp4netns installs with --configure instead.
  waitForEgress = pkgs.writeShellScript "wait-for-ci-runner-egress" ''
    attempt=0
    while [ "$attempt" -lt 20 ]; do
      if ${pkgs.iproute2}/bin/ip netns exec ${netns} ${pkgs.iproute2}/bin/ip link show tap0 2>/dev/null | ${pkgs.gnugrep}/bin/grep -q "LOWER_UP" && [ -n "$(${pkgs.iproute2}/bin/ip netns exec ${netns} ${pkgs.iproute2}/bin/ip route show default)" ]; then
        exit 0
      fi

      attempt=$((attempt + 1))
      ${pkgs.coreutils}/bin/sleep 1
    done

    exit 1
  '';
in {
  options.myHomelab.ciRunner = {
    enable = lib.mkEnableOption "self-hosted GitHub Actions runner in a NixOS container";
  };

  config = lib.mkIf cfg.enable {
    # nixos-containers bind-mounts /nix/store and the daemon socket from the
    # host, so builds run under the host nix-daemon. Container resource limits
    # isolate workflow shell steps only; they do not constrain those builds.
    containers.ci-runner = {
      autoStart = true;
      ephemeral = true;
      networkNamespace = netnsPath;
      timeoutStartSec = "5min";
      # Own UID range so container root is not host root.
      privateUsers = "pick";

      # nspawn reads the token as host root and hands it to the container as a
      # credential; a bind mount of the ramfs secret cannot be id-mapped.
      extraFlags = ["--load-credential=github_runner_token:${tokenFile}"];

      # Writable from the container so CI can leave GC roots that the host
      # daemon can resolve; see the CI workflow.
      bindMounts.${gcrootsDir} = {
        hostPath = gcrootsDir;
        isReadOnly = false;
      };

      config = {pkgs, ...}: {
        nix.settings.experimental-features = ["nix-command" "flakes"];

        # The container skips the host network setup service that feeds
        # networking.nameservers to resolvconf, so write resolv.conf directly.
        networking = {
          enableIPv6 = false;
          useHostResolvConf = false;
          resolvconf.enable = false;
        };
        environment.etc."resolv.conf".text = "nameserver 1.1.1.1\n";

        services.github-runners.nixos-ci = {
          enable = true;
          url = "https://github.com/kevinher7/nixos";
          tokenFile = "/run/host/credentials/github_runner_token";
          ephemeral = true;
          replace = true;
          extraLabels = ["nixos" "x86_64-linux"];
          extraPackages = [pkgs.git pkgs.cachix];
        };

        systemd.services.github-runner-nixos-ci.serviceConfig = {
          Restart = lib.mkForce "always";
          RestartSec = "30s";
          TimeoutStartSec = "5min";
          # The runner unit mounts the filesystem read-only; CI writes GC roots here.
          ReadWritePaths = [gcrootsDir];
        };

        system.stateVersion = config.system.stateVersion;
      };
    };

    # The namespace and slirp helper come up with the container. slirp
    # provides outbound access without host veth, NAT, or firewall rules. IPv6 stays disabled because --enable-ipv6 is omitted.
    # World-writable because the container's runner user has no host account
    # and its mapped uid may change; only this container mounts the directory.
    systemd.tmpfiles.rules = ["d ${gcrootsDir} 0777 root root -"];

    # CI builds run in the host daemon, outside the container's limits and
    # network namespace. Fixed-output derivations get network access even in
    # the sandbox, so deny the daemon everything but public addresses, and
    # bound it so a runaway build cannot take Pi-hole down with it.
    systemd.services.nix-daemon.serviceConfig = {
      # Tailscale's MagicDNS resolver sits inside the denied tailnet range.
      IPAddressAllow = ["100.100.100.100/32" "fd7a:115c:a1e0::53/128"];
      IPAddressDeny = [
        "127.0.0.0/8"
        "169.254.0.0/16"
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
        "100.64.0.0/10"
        "::1/128"
        "fe80::/10"
        "fc00::/7"
      ];
      MemoryMax = "8G";
      CPUWeight = 20;
    };

    nix.settings = {
      min-free = 50 * 1024 * 1024 * 1024;
      max-free = 100 * 1024 * 1024 * 1024;
    };

    systemd.services = {
      ci-runner-netns = {
        description = "Network namespace for the CI runner";
        partOf = ["container@ci-runner.service"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStartPre = "-${pkgs.iproute2}/bin/ip netns del ${netns}";
          ExecStart = "${pkgs.iproute2}/bin/ip netns add ${netns}";
          ExecStop = "-${pkgs.iproute2}/bin/ip netns del ${netns}";
        };
      };

      ci-runner-egress = {
        description = "Outbound network access for the CI runner";
        partOf = ["container@ci-runner.service"];
        requires = ["ci-runner-netns.service"];
        after = ["ci-runner-netns.service"];
        bindsTo = ["ci-runner-netns.service"];
        serviceConfig = {
          ExecStart = "${pkgs.slirp4netns}/bin/slirp4netns --configure --disable-host-loopback --disable-dns --netns-type=path ${netnsPath} tap0";
          ExecStartPost = waitForEgress;
          Restart = "on-failure";
          RestartSec = "5s";
          IPAddressDeny = [
            "127.0.0.0/8"
            "169.254.0.0/16"
            "10.0.0.0/8"
            "172.16.0.0/12"
            "192.168.0.0/16"
            "100.64.0.0/10"
            "::1/128"
            "fe80::/10"
            "fc00::/7"
          ];
        };
      };

      "container@ci-runner" = {
        requires = ["ci-runner-egress.service"];
        after = ["ci-runner-egress.service"];
        bindsTo = ["ci-runner-egress.service"];
        serviceConfig = {
          CPUWeight = 20;
          MemoryMax = "4G";
        };
      };
    };
  };
}
