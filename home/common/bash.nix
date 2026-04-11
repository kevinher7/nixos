{ lib, profile, hostname, ... }:
{
  programs.bash = {
    enable = true;

    shellAliases = lib.mkMerge [
      {
        # Common Aliasses
        nrs = ''sudo nixos-rebuild switch --flake ~/nixos-config#${hostname}'';
        cdnc = "cd ~/nixos-config";
      }

      # Chromebook aliases  
      (lib.mkIf (profile == "chromebook") {
        za = "zathura --fork";
      })
    ];

    initExtra = ''
      export PROMPT_COMMAND='PS1_CMD1=$(git branch --show-current 2>/dev/null)'

      ${if profile == "server" then ''
      export PS1='\u@\[\e[38;5;27m\]\H\[\e[0m\] in \[\e[38;5;67m\]\w\[\e[0m\] [\[\e[38;5;208m\]${"$"}{PS1_CMD1}\[\e[0m\]] ${"$"} '
      '' else ''
      export PS1='\[\e[38;5;93m\]\u\[\e[0m\]$ in \[\e[38;5;251m\]\w\[\e[0m\] [\[\e[38;5;196m\]${"$"}{PS1_CMD1}\[\e[0m\]] ${"$"} '
      ''}
    '';
  };
}
