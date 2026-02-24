_:
{
  programs.ghostty = {
      enable = true;
      settings = {
        # font-family = "JetBrainsMono";
        background-opacity = 0.9;
        keybind = [
          "performable:ctrl+c=copy_to_clipboard"
          "performable:ctrl+v=paste_from_clipboard"
        ];
        window-decoration = false;
        window-padding-balance = true;
        window-padding-y = 0;
        window-padding-x = 0;
        confirm-close-surface = false;
      };
  };
}
