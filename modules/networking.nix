_:
{
  networking.networkmanager.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 9300 ];
    allowedUDPPorts = [ 5353 ];
  };

  services = {
    tailscale.enable = true;
    openssh.enable = true;

    avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };
  };

}
