# 🦈 Kevin's NixOS Configuration

My personal, reproducible, and modular NixOS & Home-Manager configuration built around a single flake. This repo powers everything from a daily-driver Chromebook to a self-hosted home lab server.

---

## 🧬 Replicating the Setup

This guide assumes you already have NixOS installed.

1. **Clone the repository**

   ```bash
   git clone <repo-url> ~/nixos-config
   cd ~/nixos-config
   ```

2. **Secrets & Encryption** 🔐

   Sensitive values are encrypted with [`sops-nix`](https://github.com/Mic92/sops-nix). You will need the corresponding **age key** to decrypt the files in the `secrets/` directory. Without it, the build will fail when trying to evaluate secret references.

3. **Build & Switch**

   Run the rebuild for the specific host you are setting up:

   ```bash
   sudo nixos-rebuild switch --flake ~/nixos-config#<hostname>
   ```

   For example:

   ```bash
   sudo nixos-rebuild switch --flake ~/nixos-config#beans-btw
   sudo nixos-rebuild switch --flake ~/nixos-config#uribo-btw
   ```

---

## 🧙 Commodity Aliases

A few convenience aliases are defined in `home/common/bash.nix` to make daily interactions smoother:

| Alias | Command | Description |
|---|---|---|
| `nrs` | `sudo nixos-rebuild switch --flake ~/nixos-config#${hostname}` | Rebuilds the current host directly from the local flake. No need to remember the hostname. |
| `och` | `opencode serve --hostname 0.0.0.0 --port 4096` | Manually launches the OpenCode web interface bound to all interfaces. |
| `cdnc` | `cd ~/nixos-config` | Instantly teleport to the config directory. |

---

## 🧩 Modular Structure

The configuration is split into three main layers to keep things organized and reusable:

### `hosts/`
Entry points for each machine. A host imports its `hardware-configuration.nix` and then composes the desired system modules. For example, the `server` profile pulls in networking, services, and secrets, while the `chromebook` profile pulls in desktop, audio, and input modules.

### `modules/`
Reusable, domain-specific system modules. These are pure NixOS configurations grouped by purpose:

- **`core/`** — Base system settings, package sets, and user definitions.
- **`networking/`** — NetworkManager, firewall, and Tailscale options.
- **`services/`** — Containerized home lab services (Vaultwarden, Pi-hole, Nginx Proxy Manager).
- **`desktop/`**, **`audio/`**, **`input/`** — Hardware and user-interface layers for the laptop profile.
- **`theming/`**, **`login/`**, **`power/`**, **`secrets/`** — Stylix, display managers, power profiles, and sops-nix integration.

### `home/`
Home-Manager user-space configurations.

- **`home/hosts/`** — Per-machine Home-Manager entry points.
- **`home/common/`** — Shared settings like Bash aliases, stylix overrides, and shell configs.
- **`home/programs/`** — Individual program configs such as NixVim, Ghostty, and OpenCode.

---

## 🏠 The Home Lab & Tailscale

The server host (`uribo-btw`) acts as a lightweight home lab, running services inside Podman containers:

- **🗝️ Vaultwarden** — Self-hosted Bitwarden-compatible password manager.
- **🛑 Pi-hole** — Network-wide ad blocking and local DNS.
- **🌐 Nginx Proxy Manager** — Reverse proxy and SSL certificate management for easy external access.

All machines are connected via **[Tailscale](https://tailscale.com/)**, which forms an encrypted mesh network (tailnet) between devices no matter where they are. This means:

- The server and laptop can talk to each other securely over the internet without opening public ports.
- The server enables **Tailscale SSH** (`--ssh`), allowing remote administration without exposing the traditional OpenSSH port to the open internet.
- The `tailscale0` interface is marked as a **trusted firewall interface**, so services and administrative ports are seamlessly reachable from other tailnet devices.

---

## 💻 Using OpenCode from a Tailscale-Connected Host

OpenCode is configured to run as a **systemd user service** on the server (`home/programs/opencode.nix`), binding to `0.0.0.0` on port `4096`:

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
