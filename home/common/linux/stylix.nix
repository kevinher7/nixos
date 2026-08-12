{osConfig, ...}: {
  stylix = {
    enable = true;

    # autoEnable = false; # Disable autoEnable to avoid conflicts with NixOS level

    image = osConfig.myModules.theming.wallpaper;
    polarity = "dark";

    targets = {
      gnome.enable = false;
      rofi.enable = true;
      alacritty.enable = false;
      btop.enable = true;
      zathura.enable = true;
      qutebrowser.enable = true;
      zen-browser.enable = false;
      nixvim.enable = false;
      opencode.enable = false;
      hyprland.enable = false;
      sway.enable = false;
    };
  };
}
