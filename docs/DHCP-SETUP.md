# Pi-hole DHCP Server Setup Guide

This guide explains how to activate Pi-hole as the DHCP server in this NixOS configuration. This is useful when your ISP-provided router does not allow changing the DNS server — by making Pi-hole the DHCP server, all clients on the network will automatically use Pi-hole for DNS resolution.

> **Host:** These steps apply to the **server** host (`uribo-btw` by default). Both the hostname and username are defined in `flake.nix` and can be changed there if needed.

## Prerequisites

This guide assumes:

- You are on the current state of this repository
- The **server** host has a **static IP** configured on `enp2s0` (`192.168.0.2`)
- The Pi-hole module already has DHCP options defined (but `active = false`)
- Pi-hole DNS is already working (port 53, web UI on port 8080)

## Current State of the Config

The following is already set up declaratively:

- **Static IP** on `enp2s0` (`192.168.0.2/24`) — the server cannot be a DHCP server if its own IP is dynamic
- **DHCP module options** in `modules/services/pihole.nix`:
  - `dhcp.enable = true`
  - `dhcp.active = false` (inactive for now)
  - `dhcp.start = "192.168.0.100"`
  - `dhcp.end = "192.168.0.250"`
  - `dhcp.router = "192.168.0.1"`
  - `openFirewallDHCP = true` (port 67/UDP open)
- **Fixed local DNS entries** matching the actual `192.168.0.x` subnet

## The Setup Process

There is only **one manual step** in this entire process: disabling DHCP on the router. Everything else is declarative and managed via NixOS.

### Step 1: Activate Pi-hole DHCP (Declarative)

Edit `hosts/server/default.nix` and change:

```nix
dhcp = {
  enable = true;
  active = false;  # <-- change this to true
  router = "192.168.0.1";
  start = "192.168.0.100";
  end = "192.168.0.250";
  ...
};
```

Rebuild using flakes:

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#uribo-btw
```

Or use the `nrs` alias (available in the shell environment) for simplicity:

```bash
nrs
```

> The `nrs` alias is defined as `sudo nixos-rebuild switch --flake ~/nixos-config#${hostname}` and automatically targets the current host.

Pi-hole is now ready to serve DHCP requests.

### Step 2: Disable Router DHCP (Manual)

Log in to your router's admin panel (usually at `http://192.168.0.1`) and **disable the DHCP server**.

**Timing:** For about 10-30 seconds, both the router and Pi-hole may answer DHCP requests. This is harmless — clients will pick one and continue working. If you prefer, you can disable router DHCP first and then rebuild within 30 seconds; existing leases will keep devices online until Pi-hole takes over.

### Step 3: Verify

On any WiFi or LAN client, force a DHCP renewal:

```bash
# Linux
sudo dhclient -r && sudo dhclient

# Or toggle airplane mode on/off on a phone
```

Check that the client received an IP in the Pi-hole range:

```bash
ip addr
# Should show something like 192.168.0.10x/24
```

Check DNS is pointing to Pi-hole:

```bash
cat /etc/resolv.conf
# Should show 192.168.0.2
```

In the Pi-hole web UI (`http://192.168.0.2:8080`):

- Go to **Settings → DHCP**
- Check **"Currently active DHCP leases"** — your device should appear

## Static DHCP Leases

If you have devices that need a fixed IP (e.g., NAS, printer), add them declaratively:

```nix
dhcp = {
  ...
  staticLeases = [
    # Format: "MAC_ADDRESS,IP,hostname,leaseTime"
    "aa:bb:cc:dd:ee:ff,192.168.0.10,nas,infinite"
  ];
};
```

Then rebuild:

```bash
nrs
```

The device will receive the same IP on its next DHCP renewal.

## Rollback

If anything goes wrong, revert `hosts/server/default.nix`:

```nix
dhcp.active = false;
```

Then rebuild:

```bash
nrs
```

Finally, re-enable DHCP in your router's admin panel. All devices will fall back to the router's DHCP within the lease time (or immediately if you force a renewal).

## Network Topology

```
Internet
   |
Router (192.168.0.1)  <-- DHCP disabled here
   |
Server (192.168.0.2)  <-- Pi-hole serves DHCP + DNS
   |
WiFi / LAN Clients    <-- Get IPs + DNS from Pi-hole
```

## Notes

- The server uses Tailscale as a backup access path. If LAN connectivity breaks, you can still SSH via Tailscale.
- The server's own DNS (`nameservers` in `hosts/server/default.nix`) uses Cloudflare (`1.1.1.1`) as a fallback, independent of Pi-hole. This ensures the server can always reach the internet even if Pi-hole is restarting.
- Only **one** DHCP server should be active on the network at a time. Having two can cause "IP address conflicts" or clients flipping between DNS servers.
