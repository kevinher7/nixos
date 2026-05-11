{
  lib,
  config,
  ...
}: let
  cfg = config.myPrograms.tmux;
in {
  config = lib.mkIf cfg.enable {
    programs.tmux.enable = true;
  };
}
