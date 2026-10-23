{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.myPrograms.skim;
in {
  config = lib.mkIf cfg.enable {
    targets.darwin.defaults."net.sourceforge.skim-app.skim" = {
      SKAutoCheckFileUpdate = true;
      SKAutoReloadFileUpdate = true;
    };

    home.activation.setDefaultPdfViewer = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run ${lib.getExe pkgs.duti} -s net.sourceforge.skim-app.skim com.adobe.pdf all
    '';
  };
}
