{
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

      # pyenv
      export PYENV_ROOT="$HOME/.pyenv"
      [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
      eval "$(pyenv init - zsh)"

      # Cargo (Rust)
      export PATH="/Users/beellm/.cargo/bin:$PATH"
      export PATH="$HOME/.local/bin:$PATH"

      # Homebrew libpq
      export PATH="/usr/local/opt/libpq/bin:$PATH"
      export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

      # fnm (Fast Node Manager)
      eval "$(fnm env --use-on-cd --shell zsh)"
    '';

    shellAliases = {
      cwd = "pwd | pbcopy";
      awx = "aws-vault exec developer -- ";
      nrs = "sudo darwin-rebuild switch --flake ~/nixos-config#${hostname}";
      oca = "opencode attach http://${osConfig.myVars.serverTailscaleIP}:4096/";
      cdnc = "cd ~/nixos-config";
      och = "opencode serve --hostname 0.0.0.0 --port 4096";
      tree = "tree --gitignore";
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };
}
