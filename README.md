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

   Sensitive values are encrypted with [`sops-nix`](https://github.com/Mic92/sops-nix). The NixOS module automatically derives the age key from `/etc/ssh/ssh_host_ed25519_key` during system rebuilds, so builds work transparently. However, to **manually edit** secrets with the `sops` CLI, you need an age identity file accessible to your user.

   **One-time setup (run on your NixOS server):**

   ```bash
   mkdir -p ~/.config/sops/age

   sudo nix-shell -p ssh-to-age --run \
     "ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key" \
     > ~/.config/sops/age/keys.txt

   chmod 600 ~/.config/sops/age/keys.txt
   ```

   **Editing secrets:**

   ```bash
   nix-shell -p sops --run "sops secrets/secrets.yaml"
   ```

   Add or modify keys, save, and `sops` will re-encrypt automatically.

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
| `och`  | `opencode serve --hostname 0.0.0.0 --port 4096`                | Manually launches the OpenCode web interface bound to all interfaces.                      |
| `cdnc` | `cd ~/nixos-config`                                            | Instantly teleport to the config directory.                                                |

---

## 🧩 Modular Structure

The configuration is split into three main layers to keep things organized and reusable:

### `hosts/`

Entry points for each machine. A host imports its `hardware-configuration.nix` and then composes the desired system modules. For example, the `server` profile pulls in networking, services, and secrets, while the `chromebook` profile pulls in desktop, audio, and input modules.

### `modules/`

Reusable, domain-specific system modules. These are pure NixOS configurations grouped by purpose:

- **`core/`** — Base system settings, package sets, and user definitions.
- **`networking/`** — NetworkManager, firewall, and Tailscale options.
- **`services/`** — Home lab services (Vaultwarden, Pi-hole, native Nginx reverse proxy).
- **`desktop/`**, **`audio/`**, **`input/`** — Hardware and user-interface layers for the laptop profile.
- **`theming/`**, **`login/`**, **`power/`**, **`secrets/`** — Stylix, display managers, power profiles, and sops-nix integration.

### `home/`

Home-Manager user-space configurations.

- **`home/hosts/`** — Per-machine Home-Manager entry points.
- **`home/common/`** — Shared settings like Bash aliases, stylix overrides, and shell configs.
- **`home/programs/`** — Individual program configs such as NixVim, Ghostty, and OpenCode.

---

## 🏠 The Home Lab & Tailscale

The server host (`uribo-btw`) acts as a lightweight home lab running native NixOS services:

- **🗝️ Vaultwarden** — Self-hosted Bitwarden-compatible password manager.
- **🛑 Pi-hole** — Network-wide ad blocking and local DNS.
- **🌐 Nginx** — Native reverse proxy with automatic HTTPS via Let's Encrypt (DNS-01 challenge).

All machines are connected via **[Tailscale](https://tailscale.com/)**, which forms an encrypted mesh network (tailnet) between devices no matter where they are. This means:

- The server and laptop can talk to each other securely over the internet without opening public ports.
- The server enables **Tailscale SSH** (`--ssh`), allowing remote administration without exposing the traditional OpenSSH port to the open internet.
- The `tailscale0` interface is marked as a **trusted firewall interface**, so services and administrative ports are seamlessly reachable from other tailnet devices.

---

## ☁️ Cloudflare DNS & HTTPS

The home lab uses the personally owned domain `beanhaven.net`, with DNS hosted by **[Cloudflare](https://www.cloudflare.com/)**. Cloudflare provides DNS only; all service traffic goes directly to the server over Tailscale.

### How It Works

- **Private routing**: DNS-only A records point to the server's stable Tailscale IP. The records are publicly resolvable, but the services are reachable only from the tailnet.
- **Service domains**:
  - `beanhaven.net` → Homepage
  - `vault.beanhaven.net` → Vaultwarden
  - `pihole.beanhaven.net` → Pi-hole
  - `code.beanhaven.net` → OpenCode
  - `t3code.beanhaven.net` → T3 Code
  - `budget.beanhaven.net` → Actual Budget
  - `ai.beanhaven.net` → Open WebUI
- **DNS-01 Challenge**: Let's Encrypt certificates are obtained through Cloudflare DNS validation. No public firewall ports 80 or 443 need to be opened.

### Setting Up the Cloudflare Token

1. Create a Cloudflare API token scoped to the `beanhaven.net` zone with `Zone / Zone / Read` and `Zone / DNS / Edit` permissions.
2. Add it to the encrypted secrets:
   ```bash
   nix shell nixpkgs#sops --command sops secrets/secrets.yaml
   ```
3. Add the key:
   ```yaml
   cloudflare_dns_api_token: your-token-here
   ```
4. Save and exit — `sops` re-encrypts automatically.

The `security.acme` module uses this token only to create and remove the TXT records needed for DNS-01 challenges.

---

## 💻 Using OpenCode from a Tailscale-Connected Host

OpenCode is configured to run as a **systemd user service** on the server (`home/programs/opencode/`), binding to `0.0.0.0` on port `4096`:

```nix
programs.opencode = {
  enable = true;
  web = {
    enable = true;
    extraArgs = [ "--hostname" "0.0.0.0" "--port" "4096" ];
  };
};
```

Because it listens on all interfaces, it is accessible via the server's **Tailscale IP address** from any other device on your tailnet.

### To access it:

1. Make sure your client device is connected to the same Tailscale network.
2. Find the server's Tailscale IP (e.g., `100.x.y.z`).
3. Open your browser and navigate to:

   ```
   http://<server-tailscale-ip>:4096
   ```

### Manual Launch

If the systemd service is not running, you can also launch it manually from the server using the predefined alias:

```bash
och
```

This binds the OpenCode web UI to all interfaces, making it immediately reachable over Tailscale without any extra firewall fuss.

## License

This configuration is licensed under the MIT License. See [LICENSE](LICENSE) for the full text.

The wallpapers under `assets/wallpapers/` are third-party images and are not covered by that license.
