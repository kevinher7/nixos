{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.myPrograms.qutebrowser.enable {
    programs.mpv = {
      enable = true;
      config.stop-screensaver = true;
    };

    programs.qutebrowser.keyBindings.normal = {
      ",m" = "spawn ${lib.getExe config.programs.mpv.finalPackage} -- {url}";
      ",M" = "hint links spawn ${lib.getExe config.programs.mpv.finalPackage} -- {hint-url}";
    };
  };
}
