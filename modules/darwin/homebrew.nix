_: {
  homebrew = {
    enable = true;

    taps = [
      "nikitabobko/tap"
    ];

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      extraFlags = ["--force-cleanup"];
    };

    greedyCasks = true;

    brews = [
      "ansible"
      "openvpn"
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
      "postman"
      "raycast"
      "stats"
      "steam"
      "tailscale-app"
      "wispr-flow"
      "zoom"
    ];
  };
}
