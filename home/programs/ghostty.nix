{
  lib,
  config,
  osFamily,
  ...
}: let
  cfg = config.myPrograms.ghostty;
in {
  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      package = lib.mkIf (osFamily == "darwin") null;
      settings =
        {
          # font-family = "JetBrainsMono";
          background-opacity = 0.9;
          keybind = [
            "performable:ctrl+c=copy_to_clipboard"
            "performable:ctrl+v=paste_from_clipboard"
          ];
          window-padding-balance = true;
          window-padding-y = 0;
          window-padding-x = 0;
          confirm-close-surface = false;
        }
        // lib.optionalAttrs (osFamily == "darwin") {
          window-decoration = false;
          # Make the Option key send Alt/Meta so terminal apps (e.g. Neovim's
          # <M-arrow> window-resize maps) receive it, instead of macOS treating
          # Option as a compose key for accented characters.
          macos-option-as-alt = true;
        }
        // lib.optionalAttrs (osFamily == "linux") {
          window-decoration = false;
        };
    };
  };
}
