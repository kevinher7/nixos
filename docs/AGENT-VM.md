# Personal coding VM

`agent-dev` is a persistent NixOS guest on `uribo-btw`. T3 threads use separate
worktrees inside the guest, sharing its account, files and permissions. Laptops
and phones act as clients. The existing host T3 service stays available during
migration.

## Configuration

- `hosts/virtual/default.nix` contains common guest settings.
- `hosts/virtual/agent-dev.nix` defines the agent account, tools, T3 and store overlay.
- `modules/virtualisation/default.nix` manages the VM and its network boundary.
- `hosts/server/default.nix` enables the host module and explicitly supplies the
  domain allowlist, denied destination CIDRs, autostart choice and native
  microvm/systemd resource settings. The policy options have no defaults.

The provisional allocation is 2 virtual CPUs, 3072 MiB RAM and a 40 GiB ext4 root
disk. CPU weight is 20. The persistent root holds project checkouts, T3 history,
provider logins, the writable Nix store overlay and the Nix database. Nothing
mounts the host's home, Nix store or daemon socket. Store optimisation is disabled
because it is incompatible with the writable overlay.

The disk image lives under `/var/lib/microvms/agent-dev`. Its configured capacity
is not a reservation of host free space. Leave host disk headroom and back up the
image while the guest is stopped. Garbage collection does not delete projects,
worktrees or package-manager caches. Those require deliberate cleanup.

## Network boundary

The dedicated TAP link uses `172.31.255.1/30` on the host and `172.31.255.2/30`
in the guest. The guest has no default route, DNS service or IPv6. The host drops
forwarded traffic in both directions and guest-initiated host traffic except
connections to the HTTP proxy on port 3129. Established replies to host-initiated
management connections remain permitted.

Squid resolves destinations on the host. Its access rules allow the guest to
reach exact names in `myModules.virtualisation.allowedDomains` on ports 80 and
443, refuse the caller-supplied destination CIDRs, and deny everything else. The
proxy service enforces the same CIDR restrictions through systemd. Proxy environment
variables are supplied to shells, T3 and the guest Nix daemon. Programs ignoring
them cannot use direct internet connections. Git remotes must use HTTPS, not SSH.

The allowlist controls destinations, not repositories, accounts or request
contents. An agent can disclose guest data through permitted services. Do not
copy homelab secrets or sensitive datasets into this guest. The allowlist will
need adjustments for actual project dependencies and provider authentication.
Tools needing other protocols remain unavailable.

T3 browser previews require separate verification. Chromium may need an explicit
proxy configuration, and its first-run download may use a destination absent
from the allowlist. Do not work around this by adding a default route or disabling
Chromium's sandbox. Local development servers should use loopback.

## First deployment

The server explicitly sets autostart to false. No host capacity measurements or
guest runtime checks have been performed as part of writing this configuration.

Before deploying, verify CPU, available RAM and free disk on `uribo-btw`, including
CI and local-model workloads. Review the provisional allocation and confirm that
`172.31.255.0/30` does not overlap an existing network.

After building and deliberately deploying the server configuration:

1. Start `microvm@agent-dev` using systemd and inspect its journal.
2. Confirm the guest's private address, persistent disk and memory allocation.
3. From an authorised laptop, use
   `ssh -J uribo@uribo-btw agent@172.31.255.2` for setup. The guest admits the
   existing public keys for `kebee` and `kebean`, with no password login or sudo.
4. Authenticate providers and GitHub separately inside the guest. The host GitHub
   token and other host secrets are not supplied. Use repository-scoped GitHub
   credentials. Do not forward the laptop's SSH agent.
5. Point `agent-dev.beanhaven.net` at the server's Tailscale address using the
   existing DNS arrangement. The host requests its certificate through the
   existing DNS challenge setup. Nginx applies the existing private-device access
   rules and proxies WebSockets to guest T3 on port 3773.
6. Open that HTTPS endpoint, pair the mobile and desktop clients with guest T3,
   and add guest-owned project checkouts. Create a thread with a new worktree.
7. Verify provider calls, Git fetch/push, dependency downloads and previews.
8. Verify that direct public internet, LAN, tailnet, host SSH/DNS/HTTP, IPv6 and
   unapproved proxy destinations fail. Repeat allowed requests with Squid stopped
   to confirm there is no fallback. Test guest reboot persistence and host service
   health under a build workload.

Once capacity and runtime checks pass, set
`myModules.virtualisation.autostart = true` on the server. Host rebuilds manage
the guest configuration; stop/start the VM when a changed guest system requires
it. Rebuilding does not erase the persistent root disk. Do not delete that image
as part of routine updates.

Move selected projects and history deliberately, retaining a backup of the old
T3 state. Retire the host T3 service only after the guest workflow works. The VM
account cannot modify host firewall rules or manage its own hypervisor.
