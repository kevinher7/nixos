{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Add this for standalone WM setups
  # Source: https://github.com/NixOS/nixpkgs/issues/390071
  environment.pathsToLink = [ "/share/wireplumber" ];
}


