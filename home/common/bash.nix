{ lib, hostname, ... }:
{
  programs.bash = {
    enable = true;

    shellAliases = lib.mkMerge [
      {
        # Common Aliasses
        nrs = ''sudo nixos-rebuild switch --flake ~/nixos-config#$(hostname)'';
        cdnc = "cd ~/nixos-config";
      }

      # Chromebook aliases  
      (lib.mkIf (hostname == "chromebook") {
        za = "zathura --fork";
      })
    ];

    initExtra = ''
      export PROMPT_COMMAND='PS1_CMD1=$(git branch --show-current 2>/dev/null)'

      ${if hostname == "server" then ''
      export PS1='\[\e[38;5;27m\]\u\[\e[0m\]@\H in \[\e[38;5;67m\]\w\[\e[0m\] [\[\e[38;5;208m\]${"$"}{PS1_CMD1}\[\e[0m\]] ${"$"}
      '' else ''
      export PS1='\[\e[38;5;93m\]\u\[\e[0m\]$ in \[\e[38;5;251m\]\w\[\e[0m\] [\[\e[38;5;196m\]${"$"}{PS1_CMD1}\[\e[0m\]] ${"$"} '
      ''}
    '';
  };
}
