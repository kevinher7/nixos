_:
{
  stylix = {
    enable = true;

    # autoEnable = false; # Disable autoEnable to avoid conflicts with NixOS level

    image = ../../assets/wallpapers/girl-reading-book.png;
    polarity = "dark";

    targets = {
      rofi.enable = true;
      alacritty.enalbe = true;
      btop.enable = true;
      zathura.enable = true;
      qutebrowser.enable = true;
      nixvim.enable = false;
    };
  };
}

