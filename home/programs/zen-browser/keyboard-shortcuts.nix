{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.myPrograms.zen-browser.enable {
    programs.zen-browser.profiles.default = {
      keyboardShortcuts = [
        {
          id = "key_undoCloseWindow";
          disabled = true;
        }
        {
          id = "key_toggleReaderMode";
          disabled = true;
        }
        {
          id = "key_exitFullScreen_compat";
          disabled = true;
        }
        {
          id = "key_exitFullScreen_old";
          disabled = true;
        }
        {
          id = "key_exitFullScreen";
          disabled = true;
        }
      ];
    };
  };
}
