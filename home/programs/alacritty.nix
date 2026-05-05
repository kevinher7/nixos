{lib, ...}: {
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

        opacity = lib.mkForce 0.9;
      };

      font = {
        size = lib.mkForce 10;
      };
    };
  };
}
