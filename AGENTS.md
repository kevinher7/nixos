# NixOS configuration

The current repo is my personal NixOS configuration. This configures my system for Linux and MacOS hosts (via nix-darwin)

I have a homelab in my server host running services that are accessible via tailscale for me and other devices.

## Hosts

All hosts are x86_64-linux except `kebee`, which is aarch64-darwin via nix-darwin.

- `beans-btw`, profile `chromebook`, user `kevin`. Laptop, qtile on X11.
- `kebean`, profile `dell`, user `kevin`. Laptop, sway on Wayland.
- `uribo-btw`, profile `server`, user `uribo`. Headless homelab and CI runner.
- `kebee`, profile `macbook`, user `beellm`. Work laptop.

`mkNixosConfig` and `mkDarwinConfig` in `flake.nix` wire each host to
`hosts/<profile>/` and `home/hosts/<profile>.nix`, passing `hostname`,
`profile`, `username`, and `osFamily` to both.

## Coding Guidelines

- Do not propose or add overrides or wrappers as the default choice. Always search for the built in options or more idiomatic choices for making changes.
- The configuration should be modular. New programs or features have to me modular in the same way.
- Refactor using `git mv` to preserve history,
- Avoid adding comments to the code. The configuration should explain itself without the need of comments.

