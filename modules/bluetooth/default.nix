{pkgs, ...}: {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.pipewire.wireplumber.extraConfig."10-bluez-roles" = {
    "monitor.bluez.properties" = {
      "override.bluez5.roles" = [
        "a2dp_source"
        "bap_sink"
        "bap_source"
        "hfp_hf"
        "hfp_ag"
      ];
    };
  };

  environment.systemPackages = [pkgs.bluetui];
}
