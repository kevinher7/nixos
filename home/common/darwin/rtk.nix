{
  pkgs,
  lib,
  ...
}: {
  home.packages = [pkgs.rtk];

  home.activation.rtkInit = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD ${lib.getExe pkgs.rtk} init -g --auto-patch
  '';
}
