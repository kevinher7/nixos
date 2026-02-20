{ ... }:
{
  networking.networkmanager.enable = true;

  services.tailscale.enable = true;
  services.openssh.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 9300 ];
    allowedUDPPorts = [ 5353 ];
  };
}
