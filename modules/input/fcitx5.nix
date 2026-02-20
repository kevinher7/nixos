{ pkgs, ... }:
{
  i18n = {
    defaultLocale = "en_US.UTF-8";

    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        ignoreUserConfig = true;
        waylandFrontend = false;

        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-gtk
        ];

        settings = {
          globalOptions = {
            "Hotkey/TriggerKeys" = {
              "0" = "Zenkaku_Hankaku";
            };
          };

          inputMethod = {
            "Groups/0" = {
              Name = "Default";
              "Default Layout" = "jp";
              DefaultIM = "keyboard-jp";
            };
            "Groups/0/Items/0".Name = "keyboard-jp";
            "Groups/0/Items/1".Name = "mozc";
          };
        };
      };
    };
  };


}
