_: {
  homebrew = {
    enable = true;

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
      "cap"
      "dbeaver-community"
      "ghostty"
      "docker-desktop"
      "google-chrome"
      "postman"
      "raycast"
      "skim"
      "stats"
      "steam"
      "tailscale-app"
      "ticktick"
      "wispr-flow"
      "zoom"
    ];
  };
}
