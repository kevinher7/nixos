_:
{
  imports = [
    ./xserver.nix
    ./picom.nix
  ];

  services = {
    xserver.windowManager.qtile.enable = true;
    libinput.touchpad.naturalScrolling = true;
  };
}
