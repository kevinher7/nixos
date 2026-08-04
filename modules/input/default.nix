{lib, ...}: {
  imports = [
    ./fcitx5.nix
  ];

  options.myModules.input = {
    waylandFrontend = lib.mkEnableOption ''
      the fcitx5 Wayland input frontend. Leave off for X11 sessions, where the
      XIM/X11 frontend is what applications expect
    '';
  };
}
