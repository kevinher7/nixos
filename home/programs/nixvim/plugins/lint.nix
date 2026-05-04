{ pkgs, ... }:
{
  programs.nixvim = {
    extraPackages = with pkgs; [
      shellcheck
      markdownlint-cli
      statix
    ];

    plugins.lint = {
      enable = true;

      lintersByFt = {
        nix = [ "statix" ];
        sh = [ "shellcheck" ];
        bash = [ "shellcheck" ];
        markdown = [ "markdownlint" ];
      };
    };

    autoCmd = [
      {
        event = [ "BufWritePost" ];
        desc = "Lint on save";
        callback = {
          __raw = ''
            function()
              require('lint').try_lint()
            end
          '';
        };
      }
    ];
  };
}
