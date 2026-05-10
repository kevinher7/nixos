{
  pkgs,
  hostname,
  username,
  ...
}: {
  imports = [
    ../../modules/core/packages.nix
  ];

  networking.hostName = hostname;

  programs.zsh.enable = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  system.stateVersion = 6;

  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    brews = [
      "bun"
      "fnm"
      "gemini-cli"
      "gitleaks"
      "jq"
      "just"
      "lefthook"
      "localstack-cli"
      "pyenv"
      "tfenv"
      "terraform-docs"
      "terraform-ls"
      "tflint"
      "tmux"
      "uv"
    ];

    casks = [
      "1password-cli"
      "aerospace"
      "aws-vault-binary"
      "codex"
      "dbeaver-community"
      "gcloud-cli"
      "raycast"
      "stats"
      "visual-studio-code"
      "zen-browser"
      "zoom"
    ];
  };

  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
  };
}
