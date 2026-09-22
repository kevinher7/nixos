{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myHomelab.ciRunner;
  tokenFile = config.sops.secrets.github_runner_token.path;
  netns = "ci-runner";
  netnsPath = "/run/netns/${netns}";
  waitForEgress = pkgs.writeShellScript "wait-for-ci-runner-egress" ''
    attempt=0
    while [ "$attempt" -lt 20 ]; do
      if ${pkgs.iproute2}/bin/ip netns exec ${netns} ${pkgs.iproute2}/bin/ip link show tap0 | ${pkgs.gnugrep}/bin/grep -q "state UP" && [ -n "$(${pkgs.iproute2}/bin/ip netns exec ${netns} ${pkgs.iproute2}/bin/ip route show default)" ]; then
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
      autoStart = false;
      ephemeral = true;
      networkNamespace = netnsPath;
      timeoutStartSec = "5min";

      bindMounts.${tokenFile} = {
        hostPath = tokenFile;
        isReadOnly = true;
      };

      config = {pkgs, ...}: {
        nix.settings.experimental-features = ["nix-command" "flakes"];

        networking = {
          enableIPv6 = false;
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

        systemd.services.github-runner-nixos-ci.serviceConfig = {
          Restart = lib.mkForce "always";
          RestartSec = "30s";
          TimeoutStartSec = "5min";
        };

        system.stateVersion = config.system.stateVersion;
      };
    };

    # The namespace and slirp helper are created only when the container is
    # manually started. slirp provides outbound access without host veth, NAT,
    # or firewall rules. IPv6 stays disabled because --enable-ipv6 is omitted.
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
