_: {
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      extraFlags = ["--force-cleanup"];
    };

    greedyCasks = true;

    casks = [
      "1password"
      "1password-cli"
      "cap"
      "docker-desktop"
      "google-chrome"
      "raycast"
      "secretive"
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
