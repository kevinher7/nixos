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

  nixpkgs.config.allowUnfree = true;

  networking.hostName = hostname;

  programs.zsh.enable = true;

  # Loaded by /etc/zshenv for every shell (login or not, interactive or not),
  # so tools spawning a PTY without `-l` (e.g. t3code) still get a sane locale.
  environment.variables = {
    LANG = "en_US.UTF-8";
  };

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    extra-substituters = ["https://cache.numtide.com"];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  system = {
    stateVersion = 6;
    primaryUser = username;
    defaults = {
      dock.autohide = true;
      finder.AppleShowAllExtensions = true;
      NSGlobalDomain.AppleInterfaceStyle = "Dark";
    };
    activationScripts.aliasApplications.text = let
      aliasDir = "/Users/${username}/Applications";
      hmAppsDir = "${aliasDir}/Home Manager Apps";
    in ''
      for item in "${aliasDir}/"*.app; do
        if [ -f "$item" ] && ! [ -d "$item" ]; then
          rm -f "$item"
        fi
      done

      for app in "${hmAppsDir}/"*.app; do
        if [ -d "$app" ]; then
          ${pkgs.mkalias}/bin/mkalias "$app" "${aliasDir}/$(basename "$app")"
        fi
      done
    '';
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
      # Homebrew 5.1.14+ requires a force flag for `--cleanup`; run it non-interactively.
      extraFlags = [ "--force-cleanup" ];
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
