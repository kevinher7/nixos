{
  lib,
  pkgs,
  hostname,
  ...
}:
lib.mkIf pkgs.stdenv.isDarwin {
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;

    shellAliases = {
      drs = "darwin-rebuild switch --flake ~/nixos-config#${hostname}";
      cdnc = "cd ~/nixos-config";
      och = "opencode serve --hostname 0.0.0.0 --port 4096";
      tree = "tree --gitignore";
    };
  };
}
