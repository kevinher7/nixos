{
  hostname,
  lib,
  ...
}: {
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      extra-substituters =
        # CI builds on uribo-btw, ahead of public caches. The server itself
        # already has them and its daemon is denied loopback.
        lib.optional (hostname != "uribo-btw") "https://cache.beanhaven.net?priority=10"
        ++ [
          "https://cache.numtide.com" # For LLM Agents
          "https://kevinher7-nixos.cachix.org" # CI generated builds
        ];
      extra-trusted-public-keys = [
        "cache.beanhaven.net-1:QM0p2ysuKFpvBiCNy0Jv79uOXjxEPzvGC2nBbDP4Shk="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        "kevinher7-nixos.cachix.org-1:+Jcip/7h4fDQ2aHDQltrpnM8JgOxO754mjxRm26Rv0c="
      ];
      connect-timeout = 5;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    optimise.automatic = true;
  };

  system.stateVersion = "25.05"; # Did you read the comment?
}
