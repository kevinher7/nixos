{
  pkgs,
  hostname,
  username,
  ...
}: {
  imports = [
    ../../modules/core/packages.nix
    ../../modules/vars
  ];

  myVars = {
    serverTailscaleIP = "100.87.121.69";
  };

  networking.hostName = hostname;

  programs.zsh.enable = true;

  # Loaded by /etc/zshenv for every shell (login or not, interactive or not),
  # so tools spawning a PTY without `-l` (e.g. t3code) still get a sane locale.
  environment.variables = {
    LANG = "en_US.UTF-8";
  };

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
      cleanup = "uninstall";
      upgrade = true;
    };

    brews = [
      "cairo"
      "gemini-cli"
      "localstack-cli"
      "tfenv"
    ];

    casks = [
      "1password"
      "1password-cli"
      "aerospace"
      "codex"
      "dbeaver-community"
      "ghostty"
      "docker-desktop"
      "google-chrome"
      "postman"
      "raycast"
      "stats"
      "steam"
      "tailscale-app"
      "visual-studio-code"
      "wispr-flow"
      "zen"
      "zoom"
    ];
  };
}
