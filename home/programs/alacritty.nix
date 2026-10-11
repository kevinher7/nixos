{
  lib,
  config,
  ...
}: let
  cfg = config.myPrograms.alacritty;
in {
  config = lib.mkIf cfg.enable {
    programs.alacritty = {
      enable = true;

      settings = {
        window = {
          decorations = "None";

          padding = {
            x = 0;
            y = 0;
          };
          dynamic_padding = true;

          opacity = 0.9;
        };

        font = {
          size = 10;
        };

        keyboard.bindings = [
          {
            key = "V";
            mods = "Control";
            action = "Paste";
          }
        ];
      };
    };
  };
}
