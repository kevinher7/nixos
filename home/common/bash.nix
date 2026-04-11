{ lib, hostname, ... }:
{
  programs.bash = {
    enable = true;

    shellAliases = lib.mkMerge [
      {
        # Common Aliasses

        btw = "echo i use nixos btw";
        nrs = ''sudo nixos-rebuild switch --flake ~/nixos-config#${hostname}'';
        cdnc = "cd ~/nixos-config";

        za = "zathura --fork";
      }

      # Server aliases  
      (lib.mkIf (hostname == "server") {
        za = null;
      })
    ];

    initExtra = ''
      export PROMPT_COMMAND='PS1_CMD1=$(git branch --show-current 2>/dev/null)'

      export PS1='\[\e[38;5;93m\]\u\[\e[0m\]${if hostname == "server" then ''@\H'' else ''''} in \[\e[38;5;251m\]\w\[\e[0m\] [\[\e[38;5;196m\]${"$"}{PS1_CMD1}\[\e[0m\]] ${"$"} '
    '';
  };
}
