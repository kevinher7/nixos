{
  lib,
  config,
  ...
}: {
  programs.nixvim = {
    plugins.typst-vim = {
      enable = true;

      settings.pdf_viewer = lib.mkIf config.myPrograms.skim.enable "skim";

      keymaps = {
        watch = "<leader>tw";
      };
    };
  };
}
