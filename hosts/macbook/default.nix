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

  system = {
    stateVersion = 6;
    primaryUser = username;
    defaults = {
      dock.autohide = true;
      finder.AppleShowAllExtensions = true;
      NSGlobalDomain.AppleInterfaceStyle = "Dark";
    };
  };

  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;

    taps = [
      "nikitabobko/tap"
    ];

    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    brews = [
      "gemini-cli"
      "localstack-cli"
      "pyenv"
      "tfenv"
    ];

    casks = [
      "1password"
      "1password-cli"
      "aerospace"
      "codex"
      "dbeaver-community"
      "docker-desktop"
      "google-chrome"
      "postman"
      "raycast"
      "stats"
      "steam"
      "tailscale-app"
      "t3-code"
      "visual-studio-code"
      "wispr-flow"
      "zen"
      "zoom"
    ];
  };
}
