# Agent toolkit migration handoff

## Purpose and decisions

Continue the content migration for [nixos issue #217](https://github.com/kevinher7/nixos/issues/217)
in a dedicated session with Kevin. This is a discussion-led migration: do not
bulk-port skills or silently choose between harness-specific workflows.

- Create **agent-toolkit** as a new repository with clean history. Do not clone
  or import the history of the existing `~/.claude` repository.
- Decide visibility with Kevin before publishing any work content.
- Archive the old Claude GitHub repository only after the new repository exists
  and the selected content has been preserved. Verify its remote before archiving.
  Do not delete the live `~/.claude` directory, credentials, or sessions.
- `agent-toolkit` owns reusable skills, agents, commands, and plugins.
- `nixos` owns packages, settings, global `CONTEXT.md`, integration hooks,
  dependencies, and host enablement.
- Claude Code and the work plugin belong **only on the macbook**.
- Remove herdr entirely: no package, hook file, or SessionStart integration.
- Preserve the Chromebook's current setup: Codex, but no Claude or OpenCode.
- No content migration or live activation is authorized by this handoff alone.

## Host contract

| Nix host | Profile | User | Claude | Codex | OpenCode | Work plugin |
| --- | --- | --- | --- | --- | --- | --- |
| kebee | macbook | beellm | Yes | Yes | Yes | Yes, after content cutover |
| kebean | dell | kevin | No | Yes | Yes | No |
| uribo-btw | server | uribo | No | Yes | Yes, including web service | No |
| beans-btw | chromebook | kevin | No | Yes | No | No |

## Source inventory

The source is `/Users/beellm/.claude`, a separate Git repository. Inspect it
again when starting; the inventory below is a snapshot, not authority over later edits.

The requested untracked-file preservation is complete:

- `f43bdd81e3563b5dd19e4df4e7dc1dc0a9a3c30d`: nit reviewer agent.
- `4898508209ac23f7de6a2cd3fcfe9eac68f30641`: wizard skill and template.

Eighteen existing tracked modifications were deliberately left untouched:
15 work agents, `commands/bee-review.md`, `commands/honeycomb-review.md`, and
`skills/kevin-nit/SKILL.md`. Preserve their working-tree versions before retirement;
do not export only HEAD and lose these edits.

### Candidate portable baseline (confirm each with Kevin)

- Skills: `unslop`, `kevin-nit`, `gh`, `fetch-review`, `wizard`.
- A new shared `commit` skill, after deciding its behavior (see below).
- Agent: `agents/nit-reviewer.md`.
- Command: `home/programs/agents/commands/lint.md` in the Nix repository
  (previously `home/programs/opencode/commands/lint.md`). It runs `nix fmt`,
  so it is a Nix-project command, not a universal lint implementation.

### Candidate Claude-only work plugin

- Skills: `bee-honeycomb-check`, `dagster-navigation`, `honeycomb-navigation`,
  `review`, `type-reviewer`.
- Commands: `bee-review`, `honeycomb-review`, `rereview`.
- Agents: `company-extraction-reviewer`, `dagster-reviewer`,
  `data-quality-reviewer`, `data-validation-reviewer`, `database-reviewer`,
  `entity-api-reviewer`, `facility-reviewer`, `memory-concurrency-reviewer`,
  `patterns-reviewer`, `sns-verification-reviewer`, `sole-proprietor-reviewer`,
  `ui-performance-reviewer`, `ui-reviewer`, `web-crawling-reviewer`,
  `wide-event-logging-reviewer`.

Also inspect `.skills_archive/` with Kevin; do not automatically restore it.

## Proposed content interface

```text
agent-toolkit/
├── README.md
├── skills/<name>/SKILL.md       # Include supporting scripts/references/assets
├── agents/nit-reviewer.md
├── commands/lint.md
└── plugins/work/
    ├── .claude-plugin/plugin.json
    ├── skills/
    ├── agents/
    └── commands/
```

Commit a real manifest named `work`, with a useful description. Do not add a
Codex work-plugin manifest: work content is intentionally Claude-only.
Reserve the root skill name `work`; Home Manager uses that name for the plugin
directory and rejects collisions with baseline skills.

The baseline skills go to all enabled harnesses. Root agents and commands are
not automatically portable schemas: initially Claude consumes both, OpenCode
consumes the lint command, and Codex consumes skills. Decide additional mappings
only after verifying compatibility. Avoid wrappers and speculative adapters.

## Questions and known portability work

1. **Commit behavior:** Claude has `commands/commit.md` with `context: fork` and
   `model: sonnet`. Codex has `/Users/beellm/.codex/skills/commit/`, including a
   context-report script and a specific delegated/model-dependent workflow.
   Ask which behavior to preserve. Do not pick one merely because the names match.
2. **Script paths:** `gh` and `fetch-review` hardcode `~/.claude/skills/...`.
   Make script/reference paths resolve relative to the installed skill, not the
   project working directory or a particular harness's home directory.
3. **Plugin relocation:** `review` reads absolute old command paths and invokes
   unnamespaced `type-reviewer`; `type-reviewer` invokes scripts from its former
   `~/.claude/skills` location. Update plugin paths and references, including
   work-agent names, using the installed plugin's supported path conventions.
4. **Cross-boundary agent:** work review commands call the baseline nit reviewer.
   Preserve and test that dependency instead of blindly prefixing every agent
   name with `work:`.
5. **Dependencies:** inventory `gh`, shell/Python tools, browser automation,
   project package managers, 1Password, and project-local browser-auth scripts.
   Document project requirements separately from Nix-installed dependencies.
6. **Machine paths:** `dagster-navigation` hardcodes a macbook project location.
   Confirm whether that is intentional or should be project-relative.
7. **Metadata:** `review` and `type-reviewer` are genuinely Claude-specific.
   Audit all other skill bodies and model/tool assumptions; ignored frontmatter
   alone is not proof a workflow works in another harness.
8. **Existing Codex content:** inventory user-installed skills/plugins before
   installing a baseline with overlapping names, especially `commit`.

Use the skill-creator instructions when authoring skills. Validate metadata,
manifest structure, script syntax, executable permissions, and referenced files.
Test actual invocations as well as discovery with each intended harness.

## Nix integration contract

The Nix-side preparation lives in `home/programs/agents/`, with `default.nix`,
`claude-code.nix`, `codex.nix`, `opencode.nix`, and uppercase `CONTEXT.md`.

`myPrograms.agents.toolkitSource` is nullable during the handoff and defaults to
the `agent-toolkit` input when present. Without a source, existing loose content
is left alone; the work plugin is not installed. Macbook work enablement expresses
the target policy, not a claim that the content has already been migrated.

After the content is reviewed and committed, add a real input in `flake.nix`:

```nix
agent-toolkit = {
  url = "github:kevinher7/agent-toolkit";
  flake = false;
};
```

Confirm the owner and visibility first. Private-source fetching must work for
the intended build users/hosts without embedding credentials in Nix. Pin the
revision in `flake.lock`; do not point builds at `~/.claude` or an untracked local
checkout. A private input and plugin enablement are not confidentiality boundaries:
the fetched source may enter the Nix store on hosts that consume the flake.

Remove the temporary local lint command only after the toolkit copy is present.
Do not retire the null-source transition until all consumers can fetch the input.

### Configuration ownership

- Claude settings, formatting hook, RTK instructions, and status line are
  Nix-owned. Runtime writes to those files must not compete with Home Manager.
- RTK's activation-time `init` is removed rather than allowed to patch settings
  or context. The RTK PreToolUse hook remains declarative.
- The global shared context must remain harness-neutral; Claude-specific RTK
  instructions are added only to Claude's context.
- Codex's existing `config.toml` stays unmanaged in this preparatory PR. It has
  MCP servers, plugins/marketplaces, hooks, model preferences, project trust,
  notification settings, and a `model_instructions_file`. Review these with Kevin
  before declarative takeover; the latter may affect shared-context behavior.
- Never put auth files, secrets, runtime databases, or session history in the
  content repository or a Nix-generated configuration.

## Cutover checklist (requires an attended session)

- [ ] Confirm selected content and visibility; create and populate the clean repo.
- [ ] Preserve all remaining dirty Claude content, including anything not ported.
- [ ] Wire and lock the real input; evaluate all four hosts.
- [ ] Build/check on Darwin and Linux, including the server OpenCode service.
- [ ] Back up existing settings/context/hooks and files that Home Manager will own.
      Existing `.backup` files can also cause activation collisions.
- [ ] Check current runtime settings against the migration snapshot before switch.
- [ ] Remove the installed Homebrew Codex cask explicitly if needed; removing its
      declaration does not ensure an already-installed cask is uninstalled.
      Check whether Kevin wants the bundled desktop app retained separately.
- [ ] Activate on the macbook; check `type -a claude codex opencode` and versions.
- [ ] Test formatting, status line, and RTK rewriting in a real session.
- [ ] Remove the obsolete local `~/.claude/hooks/herdr-agent-state.sh` after
      backup; the new configuration does not install it or invoke it. Confirm
      herdr is absent from the active Nix profile after switching.
- [ ] Test baseline skills in each enabled harness and work workflows in Claude.
- [ ] Verify Claude plugin agents are discovered through Home Manager symlinks.
- [ ] Verify OpenCode uses `~/.config/opencode/skills/` (plural).
- [ ] Verify Codex/OpenCode do not discover work content indirectly through
      Claude directories. Do not assume lack of an explicit plugin entry isolates it.
- [ ] Remove old loose work skills/agents/commands only after replacements work.
- [ ] Activate Linux hosts and confirm Claude and its editor integration are absent.
- [ ] Activate again to test idempotence; retain a known-good rollback generation.
- [ ] Run repository checks and formatting validation.
- [ ] Archive the verified old Claude remote after preservation; retain runtime data.
- [ ] Update issue #217 with remaining work; close only after end-to-end acceptance.

## References and implementation baseline

- Home Manager pinned revision at handoff:
  `448c15a7fe6aa7693f63b9e8d1803bdc3dd6368d`.
- All three pinned harness modules accept source directories for skills. Use
  those options instead of adding a custom directory walker or intermediate tree.
- The pinned OpenCode module writes `opencode/skills`, not singular `skill`.
- Claude's pinned module installs modern personal plugins under `.claude/skills/`;
  it deliberately uses a whole-plugin directory link for agent discovery.
- [Claude plugin reference](https://code.claude.com/docs/en/plugins-reference)
- [Codex skills](https://developers.openai.com/codex/skills/)

Recheck pinned implementations and current harness behavior if versions change.
