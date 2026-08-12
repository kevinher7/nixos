{lib, ...}: {
  options.myModules.theming.wallpaper = lib.mkOption {
    type = lib.types.path;
    description = "Wallpaper image used by Stylix and the desktop environment.";
  };
}
