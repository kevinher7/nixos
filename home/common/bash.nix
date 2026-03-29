_:
{
  programs.bash = {
    enable = true;

    # TODO: Make flake configurable per host (use mkForce or smt)
    shellAliases = {
      btw = "echo i use nixos btw";
      nrs = ''sudo nixos-rebuild switch --flake ~/nixos-config#$(hostname)'';
      cdnc = "cd ~/nixos-config";

      za = "zathura --fork";
    };

    initExtra = ''
      export PROMPT_COMMAND='PS1_CMD1=$(git branch --show-current 2>/dev/null)'
      export PS1='\[\e[38;5;93m\]\u\[\e[0m\] in \[\e[38;5;251m\]\w\[\e[0m\] [\[\e[38;5;196m\]${"$"}{PS1_CMD1}\[\e[0m\]] ${"$"} '
    '';
  };
}
