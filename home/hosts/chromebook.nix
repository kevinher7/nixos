{pkgs, ...}: {
  imports = [../common ../programs ../desktops/qtile];

  myPrograms = {
    agents.codex.enable = true;
    alacritty.enable = true;
    betterlockscreen.enable = true;
    qutebrowser.enable = true;
    rquickshare.enable = true;
    nixvim.enable = true;
    t3code.cli.enable = true;
  };

  programs.bash.initExtra = ''
    export PROMPT_COMMAND='PS1_CMD1=$(git branch --show-current 2>/dev/null)'
    export PS1='\[\e[38;5;93m\]\u\[\e[0m\]$ in \[\e[38;5;251m\]\w\[\e[0m\] [\[\e[38;5;196m\]''${PS1_CMD1}\[\e[0m\]] $ '
  '';

  home.packages = with pkgs; [
    playerctl
    pavucontrol
    pasystray
    pcmanfm
    papirus-icon-theme
  ];
}
