# NixOS Configuration

The current project is my personal NixOS configuration in a very modular way.

The server host also contains my home lab with different services

## Code Style

- When adding new programs or features consider keeping the modularity of the config
- Do not propose ugly overrides or warppers unless deemed absolutely necessary
- Use `nix fmt` to format and run linter on files after finishing your work

## Git Hooks

This repository uses [git-hooks.nix](https://github.com/cachix/git-hooks.nix) to enforce code quality and commit conventions.

### Installing the hooks

Run the following command to generate and install the hooks into `.git/hooks`:

```bash
nix build .#checks.x86_64-linux.pre-commit-check
eval "$(nix eval --raw '.#checks.x86_64-linux.pre-commit-check.shellHook')"
```

After installation, the following checks run automatically:

- **pre-commit:** `alejandra` (formatting), `statix` (linting), `check-yaml`, `trailing-whitespace`, and `detect-private-key`
- **commit-msg:** Conventional Commits enforcement (`feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`)

### CI

The same checks are run in CI via `nix flake check` (once exported). For now, the CI runs `statix` and evaluates both NixOS configurations on every push and PR.
