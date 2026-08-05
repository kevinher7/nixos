{
  lib,
  config,
  ...
}: let
  cfg = config.myPrograms.kanshi;
in {
  config = lib.mkIf cfg.enable {
    services.kanshi = {
      enable = true;
      # kanshi applies the first profile whose outputs are all connected,
      # so the most specific (multi-monitor) profiles must come first
      settings = [
        {
          # Clamshell: external monitor is the only (principal) screen when
          # connected. eDP-1 must stay listed as disabled: kanshi still sees
          # disabled outputs when matching profiles.
          profile.name = "docked";
          profile.outputs = [
            {
              criteria = "eDP-1";
              status = "disable";
            }
            {
              criteria = "HDMI-A-1";
              status = "enable";
              position = "0,0";
            }
          ];
        }
        {
          profile.name = "undocked";
          profile.outputs = [
            {
              criteria = "eDP-1";
              status = "enable";
              position = "0,0";
            }
          ];
        }
      ];
    };
  };
}
