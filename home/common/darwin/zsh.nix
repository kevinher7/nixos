{
  config,
  hostname,
  osConfig,
  ...
}: {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    sessionVariables = {
      EDITOR = "nvim";
      # Use macOS Touch ID to unlock the aws-vault keychain instead of a password.
      AWS_VAULT_BIOMETRICS = "1";
    };

    profileExtra = ''
      # intentionally empty - see programs.zsh.initContent
    '';

    initContent = ''
      # Homebrew shellenv
      eval "$(/opt/homebrew/bin/brew shellenv)"

      # Cargo (Rust)
      export PATH="${config.home.homeDirectory}/.cargo/bin:$PATH"
      export PATH="$HOME/.local/bin:$PATH"

      # fnm (Fast Node Manager)
      eval "$(fnm env --use-on-cd --shell zsh)"

      # aws-vault wrapper using the dynamic AWS_PROFILE (set via direnv/.envrc).
      # --duration 15m caps the cached STS session at the AWS 15-minute minimum,
      # and we lock the keychain after each call so unlocking always needs a fresh
      # Touch ID tap (MFA is re-prompted once the 15-minute session expires).
      awx() {
        if [ -z "$AWS_PROFILE" ]; then
          echo "awx: AWS_PROFILE is not set (cd into a repo with an .envrc?)" >&2
          return 1
        fi
        echo "🔑 Profile: $AWS_PROFILE" >&2
        aws-vault exec --duration 15m "$AWS_PROFILE" -- "$@"
        local rc=$?
        security lock-keychain "$HOME/Library/Keychains/aws-vault.keychain-db" 2>/dev/null
        return $rc
      }

      # Runtime state for the backgrounded openvpn daemon (pid + log).
      OVPN_RUNDIR="$HOME/.cache/ovpn"
      OVPN_PIDFILE="$OVPN_RUNDIR/openvpn.pid"
      OVPN_LOGFILE="$OVPN_RUNDIR/openvpn.log"

      ovpn() {
        # Site-specific values are kept out of this (public) repo. Override them
        # in ~/.config/ovpn/env, e.g.:  OVPN_SPLIT_HOSTS="vpn-only-host.example.com"
        [ -f "$HOME/.config/ovpn/env" ] && source "$HOME/.config/ovpn/env"
        local OVPN_VAULT="''${OVPN_VAULT:-Local Development}"   # 1Password vault
        local OVPN_ITEM="''${OVPN_ITEM:-VPN}"                   # Login item: user/pass + .ovpn attachment
        local OVPN_FILE="''${OVPN_FILE:-client-config.ovpn}"    # .ovpn attachment name
        local OVPN_SPLIT_HOSTS="''${OVPN_SPLIT_HOSTS:-}"        # space-separated hosts to route via the VPN
        local user pass config

        # Refuse to stack a second tunnel on top of a running one.
        if [ -f "$OVPN_PIDFILE" ] && ps -p "$(cat "$OVPN_PIDFILE" 2>/dev/null)" >/dev/null 2>&1; then
          echo "ovpn: already connected (pid $(cat "$OVPN_PIDFILE")). Run ovpn-down first." >&2
          return 1
        fi

        user="$(op read "op://$OVPN_VAULT/$OVPN_ITEM/username")" \
          || { echo "ovpn: couldn't read username from 1Password" >&2; return 1; }

        pass="$(op read "op://$OVPN_VAULT/$OVPN_ITEM/password")" \
          || { echo "ovpn: couldn't read password from 1Password" >&2; return 1; }

        if [ -n "$1" ]; then
          config="$(cat "$1")" \
            || { echo "ovpn: couldn't read profile $1" >&2; return 1; }
        else
          config="$(op read "op://$OVPN_VAULT/$OVPN_ITEM/$OVPN_FILE")" \
            || { echo "ovpn: couldn't read profile from 1Password" >&2; return 1; }
        fi

        echo "🔐 Connecting OpenVPN as $user..." >&2
        mkdir -p "$OVPN_RUNDIR"

        # Resolve vpn target host's ips (split tunnel)
        local route_opts=() host ip
        for host in $OVPN_SPLIT_HOSTS; do
          for ip in $(dig +short "$host" | grep -E '^[0-9.]+$'); do
            route_opts+=(--route "$ip" 255.255.255.255)
          done
        done

        if [ -n "$OVPN_SPLIT_HOSTS" ] && [ ''${#route_opts[@]} -eq 0 ]; then
          echo "ovpn: warning — couldn't resolve split hosts ($OVPN_SPLIT_HOSTS); they may be unreachable" >&2
        fi

        # sudo closes inherited fds (closefrom), so /dev/fd process substitution
        # can't reach the root openvpn process. Pass the profile + credentials
        # through FIFOs instead: real paths root can open, backed only by kernel
        # buffers, so no secret is ever written to a regular file.
        local dir
        dir="$(mktemp -d)" || return 1
        local cfg="$dir/config.ovpn" auth="$dir/auth"
        mkfifo -m 600 "$cfg" "$auth"

        printf '%s\n' "$config" > "$cfg" &
        local cfg_pid=$!
        printf '%s\n%s\n' "$user" "$pass" > "$auth" &
        local auth_pid=$!

        sudo openvpn --config "$cfg" --auth-user-pass "$auth" \
          --pull-filter ignore "redirect-gateway" \
          "''${route_opts[@]}" \
          --daemon ovpn --writepid "$OVPN_PIDFILE" --log "$OVPN_LOGFILE" --verb 3
        local rc=$?

        ( sleep 10; kill "$cfg_pid" "$auth_pid" 2>/dev/null; rm -rf "$dir" ) &!

        if [ $rc -eq 0 ]; then
          echo "✅ OpenVPN started in background. Disconnect with: ovpn-down" >&2
          echo "   Status: ovpn-status   Logs: sudo tail -f $OVPN_LOGFILE" >&2
        else
          kill "$cfg_pid" "$auth_pid" 2>/dev/null
          rm -rf "$dir"
          echo "ovpn: failed to start (rc=$rc); see $OVPN_LOGFILE" >&2
        fi
        return $rc
      }

      # Stop the backgrounded openvpn tunnel.
      ovpn-down() {
        local pid
        pid="$(sudo cat "$OVPN_PIDFILE" 2>/dev/null)"
        if [ -n "$pid" ] && sudo kill "$pid" 2>/dev/null; then
          echo "🔌 OpenVPN disconnected (pid $pid)." >&2
        elif sudo pkill -x openvpn 2>/dev/null; then
          echo "🔌 OpenVPN disconnected." >&2
        else
          echo "ovpn-down: no running OpenVPN found." >&2
        fi
        sudo rm -f "$OVPN_PIDFILE"
      }

      # Show whether the tunnel is up.
      ovpn-status() {
        local pid
        pid="$(cat "$OVPN_PIDFILE" 2>/dev/null)"
        if [ -n "$pid" ] && ps -p "$pid" >/dev/null 2>&1; then
          echo "🟢 OpenVPN running (pid $pid)." >&2
        else
          echo "⚪ OpenVPN not running." >&2
        fi
      }
    '';

    shellAliases = {
      cwd = "pwd | pbcopy";
      nrs = "sudo darwin-rebuild switch --flake ~/nixos-config#${hostname}";
      oca = "opencode attach http://${osConfig.myVars.serverTailscaleIP}:${toString osConfig.myVars.opencodePort}/";
      cdnc = "cd ~/nixos-config";
      och = "opencode serve --hostname 0.0.0.0 --port ${toString osConfig.myVars.opencodePort}";
      tree = "tree --gitignore";
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
