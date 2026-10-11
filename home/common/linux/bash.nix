{hostname, ...}: {
  programs.bash = {
    enable = true;

    shellAliases = {
      nrs = ''sudo nixos-rebuild switch --flake ~/nixos-config#${hostname}'';
      cdnc = "cd ~/nixos-config";
      tree = "tree --gitignore";
    };
  };
}
