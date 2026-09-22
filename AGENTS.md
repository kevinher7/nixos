# NixOS Configuration

The current project is my personal NixOS configuration in a very modular way.

The server host also contains my home lab with different services

## Code Style

- When adding new programs or features consider keeping the modularity of the config
- Do not propose ugly overrides or warppers unless deemed absolutely necessary
- Use `nix fmt` to format and run linter on files after finishing your work
- Please prefer using `git mv` when refactoring files into other other locations to keep history clean

## Git Hooks

This repository uses [git-hooks.nix](https://github.com/cachix/git-hooks.nix) to enforce code quality and commit conventions.

### Installing the hooks

Run the following command to generate and install the hooks into `.git/hooks`:

```bash
nix develop
```

After installation, the following checks run automatically:

- **pre-commit:** `treefmt` (alejandra + statix), `check-yaml`, `trailing-whitespace`, and `detect-private-key`
- **commit-msg:** Conventional Commits enforcement (`feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`)

### CI

On every push and PR, `lint` builds `checks.x86_64-linux.pre-commit-check` and `darwin-eval` evaluates `kebee` on GitHub-hosted runners. `build` builds the three Linux hosts sequentially; it runs on the self-hosted runner container on `uribo-btw` for pushes to `main` and same-repo PRs, and on GitHub-hosted runners for fork PRs. Only pushes to `main` root the closures under `/var/lib/ci-runner/gcroots` for the Harmonia cache at `cache.beanhaven.net` and push them to Cachix. The container auto-starts, its network isolation has been verified live, and it shares the host Nix daemon, so container resource limits do not constrain Nix builds.
