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
      EDITOR = "vim";
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

      # Homebrew libpq
      export PATH="/usr/local/opt/libpq/bin:$PATH"
      export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

      # fnm (Fast Node Manager)
      eval "$(fnm env --use-on-cd --shell zsh)"

      # aws-vault wrapper using the dynamic AWS_PROFILE (set via direnv/.envrc)
      awx() {
        if [ -z "$AWS_PROFILE" ]; then
          echo "awx: AWS_PROFILE is not set (cd into a repo with an .envrc?)" >&2
          return 1
        fi
        echo "🔑 Profile: $AWS_PROFILE" >&2
        aws-vault exec "$AWS_PROFILE" -- "$@"
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
