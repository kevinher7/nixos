_: {
  homebrew = {
    enable = true;

    taps = [
      "nikitabobko/tap"
    ];

    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
      upgrade = true;
      # Homebrew 5.1.14+ requires a force flag for `--cleanup`; run it non-interactively.
      extraFlags = ["--force-cleanup"];
    };

    greedyCasks = true;

    brews = [
      "ansible"
      "sshpass"
      "tfenv"
    ];

    casks = [
      "1password"
      "1password-cli"
      "aerospace"
      "cap"
      "codex"
      "dbeaver-community"
      "ghostty"
      "docker-desktop"
      "google-chrome"
      "openvpn-connect"
      "postman"
      "raycast"
      "stats"
      "steam"
      "tailscale-app"
      "visual-studio-code"
      "wispr-flow"
      "zoom"
    ];
  };
}
