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
  };
}
