{
  config,
  hostname,
  lib,
  ...
}: {
  networking.hostName = hostname;

  myVars.harmoniaPublicKeys = {
    current = "cache.beanhaven.net-1:QM0p2ysuKFpvBiCNy0Jv79uOXjxEPzvGC2nBbDP4Shk=";
    next = null;
  };

  time.timeZone = "Asia/Tokyo";

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
        lib.optional (!config.services.harmonia.cache.enable) "https://cache.beanhaven.net?priority=10"
        ++ [
          "https://cache.numtide.com" # For LLM Agents
          "https://kevinher7-nixos.cachix.org" # CI generated builds
        ];
      extra-trusted-public-keys =
        [config.myVars.harmoniaPublicKeys.current]
        ++ lib.optional (config.myVars.harmoniaPublicKeys.next != null) config.myVars.harmoniaPublicKeys.next
        ++ [
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
