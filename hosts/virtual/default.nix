_: {
  networking = {
    useDHCP = false;
    enableIPv6 = false;
  };

  time.timeZone = "Asia/Tokyo";
  nix = {
    settings.experimental-features = ["nix-command" "flakes"];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  system.stateVersion = "25.11";
}
