# Personal Pi extensions

Home Manager builds these extensions with `package.nix` and deploys the bundled
JavaScript to `~/.pi/agent/extensions`. Effect and the TOML parser are bundled.
Pi's own packages stay external so the host supplies them.

## Behavior

- `rtk.ts` asks `rtk rewrite` to rewrite Bash commands. Unsupported commands,
  failures, and timeouts leave the original input unchanged. Use `rtk proxy`
  for unfiltered output. Other tools and user-entered shell commands are untouched.
- `format.ts` formats files after successful Pi write and edit calls. It uses
  Pi's file-mutation queue and reports formatting results in the tool response.
  Formatting failures do not change the original operation's success status.

JavaScript, TypeScript, and related text files use the nearest `package.json`.
Declared formatters take priority in this order: Biome, oxfmt, Prettier.
Python uses Ruff when the nearest `pyproject.toml` declares or configures it,
including Ruff configuration files beside that manifest. Binaries must already
exist in `node_modules/.bin`, `.venv/bin`, or `PATH`. No package manager installs
or synchronizes dependencies.

Nix files use `nix fmt` when an ancestor contains both `flake.nix` and
`treefmt.nix`. The command runs offline without updating the lockfile.
Formatter processes have a ten-second timeout and receive Pi's cancellation
signal. Unsupported files are skipped.

## Development

From this directory:

```sh
npm ci --ignore-scripts
npm run check
npm test
npm run build
pi -e ./src/format.ts -e ./src/rtk.ts
```

From the repository root:

```sh
nix build .#checks.aarch64-darwin.pi-extensions
```

Use `x86_64-linux` instead on Linux. The Nix check builds the bundles, checks
TypeScript, and runs the tests. CI runs the Linux check.

The Pi development dependency pins the API used for type checking. Update it
alongside the deployed Pi version from `llm-agents` when its API changes.
