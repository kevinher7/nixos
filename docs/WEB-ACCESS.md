# Private and shared websites

`myHomelab.webAccess` restricts nginx websites by the connecting device's IP
address. Private clients can reach every website. Guests can reach only hosts
that explicitly list them. Neither category means internet access.

Enforcement is disabled by default. Do not share the server until you have
configured private clients, enabled enforcement, deployed it, and tested it.

## Configure devices

Add this to `myHomelab` in `hosts/server/default.nix`, replacing the example
addresses with the devices' actual Tailscale addresses:

```nix
webAccess = {
  enable = true;
  privateClients = [
    "100.64.0.10"
    "fd7a:115c:a1e0::10"
  ];
  guests.friend = [
    "100.64.0.20"
    "fd7a:115c:a1e0::20"
  ];
  sharedHosts."vault.${config.myVars.domain}" = ["friend"];
};
```

Include every personal computer, phone, and automation client that needs HTTPS
access. The binary cache is private too, so include the laptops and any external
CI clients that use it. Loopback is always allowed for services on the server.
New or re-enrolled devices may need new entries. Removing an address revokes its
nginx access after deployment.

Use individual device addresses, not the whole Tailscale range. Include IPv4 and
IPv6 when clients use both. Do not add work-tailnet addresses by mistake.

## Website restrictions

The module adds private access rules to nginx's HTTP context. Existing and new
websites inherit them. Shared hosts override those rules with the private
clients plus their listed guests. Unknown hostnames go to a rejecting default
host. Vaultwarden's `/admin` prefix stays private even when the vault is shared.

Keep backend services bound to loopback. Do not add `allow`, `deny`, or
`satisfy any` directives to other server or location blocks without checking
their effect on these restrictions. Nginx replaces inherited address rules when
a child block defines its own. A location that returns a response directly can
also bypass the access phase.

Nginx checks the connecting address, not a Tailscale user or a client-supplied
forwarded header. Keep direct Tailscale-to-nginx connections. Adding another
proxy or changing nginx's real-IP settings requires reviewing this policy.

## Tailscale permissions

Share `uribo-btw` with the friend's own Tailscale account instead of adding them
as a tailnet member. In the Tailscale admin console's access policy, allow the
friend's login email to reach only TCP port 443 on `100.87.121.69`.

Remove or narrow any wildcard rules that also grant shared users broader
access. Grants and legacy ACLs add permissions together. Nginx restrictions do
not block SSH or other ports; the Tailscale policy must do that.

## Verify before sharing

From a private device, check the vault, dashboard, Pi-hole, budget, and binary
cache. They should work as before.

From the guest device, check:

- `https://vault.beanhaven.net/` reaches Vaultwarden.
- `/admin` and `/admin/` on the vault return 403.
- The dashboard, Pi-hole, budget, API, and cache return 403.
- Unknown hostnames do not fall back to a service.
- SSH and other server ports are unreachable through Tailscale.

Repeat HTTP checks over IPv4 and IPv6 when both are configured. Confirm that a
device with no nginx permission cannot reach any service. Use a separate
Vaultwarden account for the guest and keep open registration disabled.
