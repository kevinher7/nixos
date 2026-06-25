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

      ovpn() {
        local OVPN_VAULT="Local Development"   # 1Password vault holding the item
        local OVPN_ITEM="VPN"                  # Login item: username + password + .ovpn attachment
        local OVPN_FILE="client-config.ovpn"   # .ovpn file attached to the item
        local user pass config

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

        sudo openvpn --config "$cfg" --auth-user-pass "$auth"
        local rc=$?

        kill "$cfg_pid" "$auth_pid" 2>/dev/null
        rm -rf "$dir"
        return $rc
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
