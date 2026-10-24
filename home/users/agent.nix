_: {
  imports = [../common ../programs];

  myPrograms = {
    agents = {
      claude-code.enable = true;
      codex.enable = true;
      opencode.enable = true;
      pi.enable = true;
    };
    t3code.cli.enable = true;
  };

  programs.bash.initExtra = ''
    export PROMPT_COMMAND='PS1_CMD1=$(git branch --show-current 2>/dev/null)'
    export PS1='\u@\[\e[38;5;27m\]\H\[\e[0m\] in \[\e[38;5;67m\]\w\[\e[0m\] [\[\e[38;5;208m\]''${PS1_CMD1}\[\e[0m\]] $ '
  '';
}
