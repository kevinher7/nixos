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

      awx() {
        local profile="$AWS_PROFILE"
        if [ "$1" = "-p" ]; then
          if [ -z "$2" ]; then
            echo "awx: -p needs a profile name" >&2
            return 1
          fi
          profile="$2"
          shift 2
        fi
        if [ -z "$profile" ]; then
          echo "awx: no profile (set AWS_PROFILE via .envrc, or pass -p <profile>)" >&2
          return 1
        fi
        echo "🔑 Profile: $profile" >&2
        aws-vault exec --duration 15m "$profile" -- "$@"
        local rc=$?
        security lock-keychain "$HOME/Library/Keychains/aws-vault.keychain-db" 2>/dev/null
        return $rc
      }

      tfp() {
        local prof=()
        if [ "$1" = "-p" ]; then
          prof=(-p "$2")
          shift 2
        fi
        awx "''${prof[@]}" terraform plan -no-color "$@" \
          | tee >(awk '/^Terraform used the selected providers/{p=1} p{print} /^Plan: [0-9]/{p=0}' | pbcopy)
        return ''${pipestatus[1]}
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
