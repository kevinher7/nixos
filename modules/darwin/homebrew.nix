_: {
  homebrew = {
    enable = true;

    taps = [
      {
        name = "nikitabobko/tap";
        trusted = true;
      }
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
