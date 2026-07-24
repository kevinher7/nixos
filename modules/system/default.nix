_: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    # kevinher7-nixos holds the CI-built closures for the x86_64-linux hosts.
    # Without it these machines rebuild every path the config makes custom
    # (notably the pythonPackagesExtensions overlay in ../overlays) from source.
    extra-substituters = [
      "https://cache.numtide.com"
      "https://kevinher7-nixos.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "kevinher7-nixos.cachix.org-1:+Jcip/7h4fDQ2aHDQltrpnM8JgOxO754mjxRm26Rv0c="
    ];
  };

  system.stateVersion = "25.05"; # Did you read the comment?
}
