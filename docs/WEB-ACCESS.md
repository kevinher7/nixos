# Private and shared websites

`myHomelab.webAccess` restricts nginx websites by device IP address. Private
clients can reach every website. Each shared host adds its own guest addresses.
New websites stay private. Vaultwarden's `/admin` prefix always stays private.

Enforcement is disabled until you configure and enable it. Add this to
`myHomelab` in `hosts/server/default.nix`, using your actual Tailscale addresses:

```nix
webAccess = {
  enable = true;
  privateClients = [
    "100.64.0.10"
    "fd7a:115c:a1e0::10"
  ];
  sharedHosts."vault.${config.myVars.domain}" = [
    "100.64.0.20"
    "fd7a:115c:a1e0::20"
  ];
};
```

Include your computers, phone, and automation clients in `privateClients`.
The binary cache is private too. Loopback is always allowed. Use individual
addresses, including IPv6 where used, not the whole Tailscale range. An empty
private list allows only loopback on private sites.

Keep backends bound to loopback and connections direct from Tailscale to nginx.
Additional proxies or real-IP settings need a policy review. Nginx replaces
inherited address rules when a server or location defines its own `allow` or
`deny`. Avoid `satisfy any` or direct-response locations on protected routes.

Before sharing `uribo-btw`, restrict the friend's Tailscale permissions to TCP
443 on `100.87.121.69`. Narrow any broader wildcard grants or ACLs. These nginx
rules do not restrict SSH or other ports. Neither private nor shared websites
need internet exposure.

After deploying, verify your devices can still reach every service. From the
guest device, only the vault should work. Other websites and the vault's
`/admin` and `/admin/` should return 403. Unknown hostnames should be rejected.
Check both IP families where used. Then invite the friend to a separate
Vaultwarden account, keeping open registration disabled.
