{
  lib,
  config,
  ...
}: {
  programs.nixvim = {
    plugins.typst-vim = {
      enable = true;

      settings.pdf_viewer = lib.mkIf config.myPrograms.zathura.enable (lib.getExe config.programs.zathura.package);

      keymaps = {
        watch = "<leader>w";
      };
    };
  };
}
