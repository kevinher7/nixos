{
  self,
  pkgs,
}: let
  inherit (pkgs) lib;
  macbookSystem = self.darwinConfigurations.kebee;
  macbook = macbookSystem.config.home-manager.users.beellm;
  dell = self.nixosConfigurations.kebean.config.home-manager.users.kevin;
  server = self.nixosConfigurations.uribo-btw.config.home-manager.users.uribo;
  chromebook = self.nixosConfigurations.beans-btw.config.home-manager.users.kevin;
  linuxHomes = [dell server chromebook];
  source = ./fixtures/agent-toolkit;
  withSource =
    (macbookSystem.extendModules {
      modules = [{home-manager.users.beellm.myPrograms.agents.toolkitSource = lib.mkForce source;}];
    }).config.home-manager.users.beellm;
  withoutSource =
    (macbookSystem.extendModules {
      modules = [{home-manager.users.beellm.myPrograms.agents.toolkitSource = lib.mkForce null;}];
    }).config.home-manager.users.beellm;
  withoutWork =
    (macbookSystem.extendModules {
      modules = [
        {
          home-manager.users.beellm.myPrograms.agents = {
            toolkitSource = lib.mkForce source;
            work.enable = lib.mkForce false;
          };
        }
      ];
    }).config.home-manager.users.beellm;
  checks = {
    macbookHarnesses = macbook.programs.claude-code.enable && macbook.programs.codex.enable && macbook.programs.opencode.enable;
    linuxWithoutClaude = lib.all (home: !home.programs.claude-code.enable && !home.myPrograms.agents.work.enable) linuxHomes;
    linuxWithoutClaudeEditor = lib.all (home: !home.programs.nixvim.plugins.claudecode.enable) linuxHomes;
    linuxWithoutClaudeDependency = lib.all (home: !home.programs.nixvim.dependencies.claude-code.enable) linuxHomes;
    codexEverywhere = lib.all (home: home.programs.codex.enable) ([macbook] ++ linuxHomes);
    chromebookWithoutOpenCode = !chromebook.programs.opencode.enable;
    openCodeOnDell = dell.programs.opencode.enable;
    serverWeb = server.programs.opencode.web.enable && server.systemd.user.services.opencode-web.Service.WorkingDirectory == "/home/uribo/nixos-config";
    noWebOnClients = !macbook.programs.opencode.web.enable && !dell.programs.opencode.web.enable;
    noCodexCask = lib.all (cask: cask.name != "codex") macbookSystem.config.homebrew.casks;
    noRtkInit = !(macbook.home.activation ? rtkInit);
    rtkHook = lib.hasSuffix "/bin/rtk hook claude" (builtins.head (builtins.head macbook.programs.claude-code.settings.hooks.PreToolUse).hooks).command;
    noHerdrHook = !(macbook.programs.claude-code.settings.hooks ? SessionStart);
    noHerdrPackage = lib.all (home: lib.all (package: lib.getName package != "herdr") home.home.packages) ([macbook] ++ linuxHomes);
    noSourceNoPlugin = withoutSource.programs.claude-code.plugins == {};
    noSourceNoSkills = withoutSource.programs.claude-code.skills == {} && withoutSource.programs.codex.skills == {} && withoutSource.programs.opencode.skills == {};
    preserveCodexSettings = withoutSource.programs.codex.settings == null;
    sharedSkills = lib.all (program: program.skills == "${source}/skills") [withSource.programs.claude-code withSource.programs.codex withSource.programs.opencode];
    workPluginSource = withSource.programs.claude-code.plugins.work == "${source}/plugins/work";
    workToggle = withoutWork.programs.claude-code.plugins == {};
    rootAgents = withSource.programs.claude-code.agentsDir == "${source}/agents";
    rootCommands = withSource.programs.claude-code.commandsDir == "${source}/commands";
    lintContent = withSource.programs.opencode.commands.lint == builtins.readFile (source + "/commands/lint.md");
    sharedContext = macbook.programs.codex.context == ../home/programs/agents/CONTEXT.md && macbook.programs.opencode.context == ../home/programs/agents/CONTEXT.md;
  };
  failures = lib.attrNames (lib.filterAttrs (_: passed: !passed) checks);
in
  assert lib.assertMsg (failures == []) "Agent configuration checks failed: ${lib.concatStringsSep ", " failures}";
    pkgs.runCommand "agent-configuration-check" {
      nativeBuildInputs = [pkgs.python3 pkgs.bash pkgs.jq];
    } ''
      bash -n ${../home/programs/agents/statusline-context.sh}
      python3 -c 'import ast, pathlib, sys; ast.parse(pathlib.Path(sys.argv[1]).read_text())' \
        ${../home/programs/agents/hooks/format-on-save.py}
      printf '{}' | python3 ${../home/programs/agents/hooks/format-on-save.py}
      printf '%s' '{"context_window":{"used_percentage":42}}' \
        | bash ${../home/programs/agents/statusline-context.sh} | grep -q '42% used'
      ${lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
        test -f ${withSource.home.file."/Users/beellm/.claude/skills".source}/example/SKILL.md
        test -f ${withSource.home.file.".codex/skills".source}/example/SKILL.md
        test -f ${withSource.xdg.configFile."opencode/skills".source}/example/SKILL.md
        grep -q 'Fixture lint command' ${withSource.xdg.configFile."opencode/commands/lint.md".source}
        test -f ${withSource.home.file."/Users/beellm/.claude/skills/work".source}/agents/reviewer.md
        test ! -L ${withSource.home.file."/Users/beellm/.claude/skills/work".source}/agents/reviewer.md
      ''}
      touch "$out"
    ''
