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

On every push and PR, the `lint` job builds `checks.x86_64-linux.pre-commit-check`, which runs the same hooks over the whole tree. The `eval` job evaluates the darwin host (`kebee`), and the `build` job builds the three Linux hosts and pushes the results to Cachix.
