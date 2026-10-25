# 🦈 Kevin's NixOS Configuration

My personal, reproducible, and modular NixOS & Home-Manager configuration built around a single flake. This repo powers everything from a daily-driver Chromebook to a self-hosted home lab server.

| Host        | Profile      | User     | Platform       | Desktop        |
| ----------- | ------------ | -------- | -------------- | -------------- |
| `beans-btw` | `chromebook` | `kevin`  | x86_64-linux   | qtile (X11)    |
| `kebean`    | `dell`       | `kevin`  | x86_64-linux   | sway (Wayland) |
| `uribo-btw` | `server`     | `uribo`  | x86_64-linux   | headless       |
| `kebee`     | `macbook`    | `beellm` | aarch64-darwin | macOS          |

---

## 🧬 Replicating the Setup

This guide assumes you already have NixOS installed.

1. **Clone the repository**

   ```bash
   git clone <repo-url> ~/nixos-config
   cd ~/nixos-config
   ```

2. **Install Git Hooks** 🪝

   ```bash
   nix develop
   ```

   This installs the git hooks (formatting, linting, conventional commits). See `AGENTS.md` for details.

3. **Secrets & Encryption** 🔐

   Sensitive values are encrypted with [`sops-nix`](https://github.com/Mic92/sops-nix). `.sops.yaml` decides which age keys can decrypt each file:

   ```text
   secrets/
   ├── hosts/
   │   ├── kebean.yaml
   │   ├── kebee.yaml
   │   └── uribo-btw.yaml
   └── services/
       ├── mail-bean.yaml
       └── t3code.yaml
   ```

   Each host decrypts `secrets/hosts/<hostname>.yaml`, which `modules/secrets` sets as the default sops file, plus the files in `secrets/services/` for the services it runs. Each service file goes to the hosts running that service: `secrets/services/t3code.yaml` to every host running the T3 Code server, `secrets/services/mail-bean.yaml` to the server. The modules that read them set `sopsFile` explicitly. Hosts decrypt at activation with the age key that sops-nix derives from `/etc/ssh/ssh_host_ed25519_key`, which only root can read, so no age key file sits in any home directory.

   A dedicated admin age key is a recipient of every file, and it is the only key meant for editing. It is protected by a passphrase, lives on kebean, and is backed up in Vaultwarden with the passphrase stored separately. YubiKeys can join later as extra admin recipients. No other user-readable key may decrypt secrets. Anything running as that user, coding agents included, could read every secret it can decrypt, the Harmonia signing key among them.

   **Editing secrets:**

   Edit on kebean, either at the machine or over SSH from the macbook (`ssh kevin@kebean`, which asks for Touch ID through Secretive). `sops` then asks for the admin key's passphrase.

   ```bash
   nix shell nixpkgs#sops --command sops secrets/hosts/uribo-btw.yaml
   ```

   Add or modify keys, save, and `sops` re-encrypts the file.

   **Removing a recipient:**

   Change `.sops.yaml`, then run both commands on every affected file:

   ```bash
   sops updatekeys secrets/hosts/uribo-btw.yaml
   sops rotate -i secrets/hosts/uribo-btw.yaml
   ```

   `updatekeys` alone keeps the old data key, so the removed key can still decrypt a copy from git history. `rotate` replaces the data key. Old ciphertext stays in git either way, so also rotate the real secrets the removed key could read.

   **Rotating the Harmonia signing key:**

   Harmonia signs with `harmonia_signing_key`, and every NixOS host trusts `myVars.harmoniaPublicKeys.current`, set in `modules/system/default.nix`. A rotation takes two deploys, so no host ever gets a path signed only by a key it doesn't trust yet.

   Phase 1 adds the next key next to the current one. On kebean, with `<n>` one higher than the number in the current key name:

   ```bash
   key=$(nix key generate-secret --key-name cache.beanhaven.net-<n>)
   printf '%s' "$key" | jq -Rs . | sops set --value-stdin secrets/hosts/uribo-btw.yaml '["harmonia_signing_key_next"]'
   printf '%s' "$key" | nix key convert-secret-to-public
   unset key
   ```

   Set `myVars.harmoniaPublicKeys.next` to the printed public key. While `next` is set, the server signs with both keys and every NixOS host trusts both. Merge, then deploy every NixOS host with `nix run .#fleet-deploy`.

   Phase 2 promotes the next key. Copy the value of `harmonia_signing_key_next` into `harmonia_signing_key` with `sops secrets/hosts/uribo-btw.yaml` and delete `harmonia_signing_key_next`. In Nix, move the `next` public key to `current` and set `next = null`. Merge and deploy every host again.

   **Rotating secrets with the wizard:**

   Run `nix run .#rotate-secrets` on kebean. The table at the top of `scripts/rotate-secrets/script.sh` lists every secret, its file and how to get a new value, and the wizard warns when a host declares a secret the table lacks. Pick secrets, then for each one it generates a value, or shows the dashboard to create one in and reads it without echo. Values go from memory straight into `sops set`. It commits the changed files on a `chore/rotate-secrets-<date>` branch and opens a PR. The Harmonia key follows the two phases above, one per run, and the wizard prints the Nix edits to push to that PR.

   After merging and deploying with fleet-deploy, run `nix run .#rotate-secrets -- --resume` for the verification commands and the checklist of old credentials to revoke. Progress lives in `~/.local/state/rotate-secrets/`, without values.

4. **Build & Switch**

   Run the rebuild for the specific host you are setting up:

   ```bash
   sudo nixos-rebuild switch --flake ~/nixos-config#<hostname>
   ```

   For example:

   ```bash
   sudo nixos-rebuild switch --flake ~/nixos-config#beans-btw
   sudo nixos-rebuild switch --flake ~/nixos-config#kebean
   sudo nixos-rebuild switch --flake ~/nixos-config#uribo-btw
   ```

---

## 🧙 Commodity Aliases

A few convenience aliases are defined in `home/common/linux/bash.nix` to make daily interactions smoother:

| Alias  | Command                                                        | Description                                                                                |
| ------ | -------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| `nrs`  | `sudo nixos-rebuild switch --flake ~/nixos-config#${hostname}` | Rebuilds the current host directly from the local flake. No need to remember the hostname. |
| `cdnc` | `cd ~/nixos-config`                                            | Instantly teleport to the config directory.                                                |

To bump a subset of flake inputs and open a PR, run `nix run .#update-inputs`.
It shows a checklist of the fast-moving inputs, updates `flake.lock` on a new
branch, and creates the PR with the same body format as the weekly workflow.
Pass input names as arguments to skip the prompt.

To roll the latest `main` out to the whole fleet at once, run
`nix run .#fleet-deploy`. It opens an SSH connection to each host over
tailscale (the host it runs on is handled locally), pulls `main`, runs the
rebuild on all of them in parallel and shows which hosts are still building and
which are done. The first stage lists the fleet so hosts can be toggled on and
off; `beans-btw` starts off. `uribo-btw` and the darwin hosts rebuild first,
since darwin does not pull from `cache.beanhaven.net`, and the remaining linux
hosts start once that cache answers again. The remote hosts share one sudo
password; the host you run it from authenticates its own sudo directly, so
Touch ID works there.

---

## 🧩 Modular Structure

The system and Home Manager configuration lives in `hosts/`, `modules/`, and `home/`. Repository maintenance commands live in `scripts/`.

### `hosts/`

Entry points for each machine. A host imports its `hardware-configuration.nix` and then composes the desired system modules. For example, the `server` profile pulls in networking, services, and secrets, while the `chromebook` profile pulls in desktop, audio, and input modules.

### `modules/`

Reusable, domain-specific system modules. These are pure NixOS configurations grouped by purpose:

- **`core/`** — Base system settings, package sets, and user definitions.
- **`networking/`** — NetworkManager, firewall, and Tailscale options.
- **`services/`** — Home lab services (Vaultwarden, Pi-hole, native Nginx reverse proxy, the CI runner container).
- **`t3code/`** — The T3 Code headless server, imported by every NixOS host.
- **`agent-user/`** — The unprivileged `agent` account on the server that runs the T3 Code server and the coding-agent CLIs, kept apart from the admin user. Its Home-Manager profile is `home/users/agent.nix`.
- **`desktop/`**, **`audio/`**, **`input/`** — Hardware and user-interface layers for the laptop profile.
- **`theming/`**, **`login/`**, **`power/`**, **`secrets/`** — Stylix, display managers, power profiles, and sops-nix integration.

### `home/`

Home-Manager user-space configurations.

- **`home/hosts/`** — Per-machine Home-Manager entry points.
- **`home/common/`** — Shared settings like Bash aliases, stylix overrides, and shell configs.
- **`home/programs/`** — Individual program configs such as NixVim, Ghostty, and OpenCode.

### `scripts/`

Each maintenance command has a directory containing `script.sh`, its Nix package in `default.nix`, and any supporting files. Register new commands in `scripts/default.nix` to expose them through `nix run .#<command>`. Keep runtime dependencies and ShellCheck exclusions in the command's package definition.

The flake exposes `fleet-deploy`, `rotate-secrets`, `update-inputs`, and `t3-renew` on Linux and macOS. Run commands that edit this repository from its checkout. `reload-quickshell.sh` remains a direct development helper for the local QML checkout.

---

## 🏠 The Home Lab & Tailscale

The server host (`uribo-btw`) acts as a lightweight home lab running native NixOS services:

- **🗝️ Vaultwarden** — Self-hosted Bitwarden-compatible password manager.
- **🛑 Pi-hole** — Network-wide ad blocking and local DNS.
- **🌐 Nginx** — Native reverse proxy with automatic HTTPS via Let's Encrypt (DNS-01 challenge).
- **📦 Harmonia** — Binary cache serving the server's Nix store at `cache.beanhaven.net`. Every push to `main` roots the freshly built host closures there, so other hosts substitute from the LAN instead of downloading from Cachix.
- **🏗️ CI runner** — A self-hosted GitHub Actions runner runs in a fenced NixOS container. It builds the Linux hosts for pushes to `main` and for PRs from branches in this repository; PRs from forks stay on GitHub-hosted runners.

The runner uses a separate network namespace with `slirp4netns` for outbound access and denies LAN, tailnet, loopback, and IPv6-local ranges through systemd IP filtering. Its workflow shell is isolated, but builds submitted to the shared host Nix daemon remain outside the container's resource limits.

On warm runs the self-hosted build job takes about 100 seconds against roughly 300 seconds on GitHub-hosted runners. If the container is down, `build` jobs queue until `container@ci-runner` is back. Only pushes to `main` keep GC roots for the cache and push to Cachix; PR builds are discarded at the next garbage collection.

All machines are connected via **[Tailscale](https://tailscale.com/)**, which forms an encrypted mesh network (tailnet) between devices no matter where they are. This means:

- The server and laptop can talk to each other securely over the internet without opening public ports.
- The server enables **Tailscale SSH** (`--ssh`), allowing remote administration without exposing the traditional OpenSSH port to the open internet.
- The firewall opens only SSH (22) on `tailscale0` on every host, plus HTTP and HTTPS (80, 443) on the server for nginx. Every homelab service is reached through its nginx domain; the backends listen on `127.0.0.1`.

---

## ☁️ Cloudflare DNS & HTTPS

The home lab uses the personally owned domain `beanhaven.net`, with DNS hosted by **[Cloudflare](https://www.cloudflare.com/)**. Cloudflare provides DNS only; all service traffic goes directly to the server over Tailscale.

### How It Works

- **Private routing**: DNS-only A records point to the server's stable Tailscale IP. The records are publicly resolvable, but the services are reachable only from the tailnet.
- **Service domains**:
  - `beanhaven.net` → Homepage
  - `vault.beanhaven.net` → Vaultwarden
  - `pihole.beanhaven.net` → Pi-hole
  - `budget.beanhaven.net` → Actual Budget
- **DNS-01 Challenge**: Let's Encrypt certificates are obtained through Cloudflare DNS validation. No public firewall ports 80 or 443 need to be opened.

### Setting Up the Cloudflare Token

1. Create a Cloudflare API token scoped to the `beanhaven.net` zone with `Zone / Zone / Read` and `Zone / DNS / Edit` permissions.
2. Add it to the encrypted secrets:
   ```bash
   nix shell nixpkgs#sops --command sops secrets/hosts/uribo-btw.yaml
   ```
3. Add the key:
   ```yaml
   cloudflare_dns_api_token: your-token-here
   ```
4. Save and exit — `sops` re-encrypts automatically.

The `security.acme` module uses this token only to create and remove the TXT records needed for DNS-01 challenges.

### Tailscale Split DNS

Some mobile carriers and DNS resolvers block public DNS answers containing Tailscale addresses as protection against DNS rebinding. To keep the homelab names working on mobile data, configure a restricted nameserver in the [Tailscale DNS admin page](https://login.tailscale.com/admin/dns):

1. Add `1.1.1.1` as a custom nameserver.
2. Restrict it to `beanhaven.net` so only the homelab domain uses it.
3. Optionally add `1.0.0.1` with the same restriction for redundancy.
4. Ensure **Use Tailscale DNS settings** is enabled on each client.

This split-DNS route avoids affected local resolvers without overriding DNS for unrelated domains. See Tailscale's [DNS rebinding guidance](https://tailscale.com/docs/reference/faq/dns-rebinding) and [split-DNS documentation](https://tailscale.com/docs/reference/dns-in-tailscale).

---

## Coding agents

`home/programs/agents/` configures the coding harnesses through
`myPrograms.agents`. Claude Code, Codex, OpenCode and pi are enabled on every
host. On the server they run as the `agent` account (`modules/agent-user/`),
not as the admin user. pi reads the OpenRouter key only where
`myPrograms.agents.pi.useOpenrouter` is on (macbook and Dell).

Shared global instructions live in `home/programs/agents/CONTEXT.md`. Claude's
settings, hooks, status line, and RTK integration are declarative; do not run
`rtk init` or integration installers that rewrite those files. Codex's
`config.toml` and `hooks.json` are declarative too. The config file stays
writable so Codex can record hook trust and newly trusted projects, and the
declared values win on every `home-manager switch`. Both harnesses run
without approval prompts and with full filesystem access by default. Codex has no MCP servers
or plugins declared; the desktop app may add its own to the writable file.

The [agent-toolkit](https://github.com/kevinher7/agent-toolkit) repository supplies
reusable content through a pinned non-flake input. Its shared skills are installed
for every enabled harness. Claude and OpenCode also get `/nix-lint`.
`myPrograms.agents.work-toolkit.enable` installs the Claude-only work plugin on
the macbook, exposing its namespaced commands, skills, and specialist agents.
Update the `agent-toolkit` flake input and rebuild to deploy content changes.

Before the first switch, back up and remove obsolete loose skills, agents, and
commands that have moved into the work plugin; Home Manager does not remove
previously unmanaged files. Verify other harnesses do not discover leftover work
content through Claude's directories.
Do not switch without backing up conflicting local files. The removed Homebrew
Codex cask may also need an explicit uninstall to stop shadowing the Nix CLI.

## 🤖 T3 Code on Every NixOS Host

Every NixOS host runs its own T3 Code server (`modules/t3code/`), as `kevin` on
the laptops and as the unprivileged `agent` account on `uribo-btw`, listening on
plain HTTP at `http://<host>:3773`. The firewall opens that
port on `tailscale0` only, so the server is reachable from the tailnet and
nowhere else. There is no browser endpoint anymore; the T3 Code desktop and
mobile apps connect to each host directly, and `uribo-btw` never proxies agent
traffic for the others. Every machine owns its projects, provider logins and
sessions. Agents run in `~/projects`, and state lives in `/var/lib/t3code`.

### Pairing a Host

Pair each host once, as the service user rather than root, so the credentials
land in the same state directory the service uses:

```bash
sudo -u kevin t3 pair --base-dir /var/lib/t3code --label kebean
sudo -u agent t3 pair --base-dir /var/lib/t3code --label uribo-btw
```

In the desktop app, open Settings > Connections > Add environment and paste the
full printed link. On the phone, it is Settings > Environments, where you can
scan the QR code the helper prints under the link. The link expires
after five minutes. Pairing survives service restarts and reboots. Use `t3 auth`
to list or revoke old sessions.

Sessions expire after 30 days. From the repository root, generate a fresh
pairing link with:

```bash
nix run .#t3-renew -- kebean
```

The helper accepts `uribo-btw`, `kebean`, or `beans-btw`. It connects over SSH as
the host's admin user and runs `t3` as the T3 service user with `sudo -u`, so it
asks for that host's sudo password when T3 runs as `agent`. The `agent` accounts
don't accept SSH logins from your machines. Pairing the same host again replaces its saved credentials in the apps.
The helper uses the existing `/var/lib/t3code` state and leaves old sessions in
place.

Providers authenticate per host, so `codex` and `claude` need a login on each
machine as that machine's user.

### Turning It Off

Set `myModules.t3code.enable = false` on the host and rebuild. Leave
`/var/lib/t3code` alone so the environment and its sessions stay recoverable.

## License

This configuration is licensed under the MIT License. See [LICENSE](LICENSE) for the full text.

The wallpapers under `assets/wallpapers/` are third-party images and are not covered by that license.
