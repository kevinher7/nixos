# Private and shared websites

`myHomelab.webAccess` restricts nginx websites by device IP address. Private
clients can reach every website. Each shared host adds its own guest groups.
New websites stay private. Vaultwarden's `/admin` prefix always stays private.

Device inventory and group membership live in `devices.nix`, shared by NixOS
and Darwin configurations. Register each device once with its Tailscale IPv4
and IPv6 addresses, then add its name to the appropriate group:

```nix
myDevices = {
  devices.newPhone.addresses = ["100.64.0.10" "fd7a:115c:a1e0::10"];
  groups.private = ["newPhone"];
};
```

The `private` group contains personal computers, the server, and the Pixel 9a.
The `vaultGuests` group contains `njqm10`. A device can belong to multiple
groups. Registry names are local configuration labels, not Tailscale tags or
authenticated usernames. Registering a device alone grants no access.

Website policy stays in `hosts/server/default.nix`:

```nix
webAccess = {
  enable = true;
  privateGroups = ["private"];
  sharedHosts."vault.${config.myVars.domain}".groups = ["vaultGuests"];
};
```

Unknown device or group references fail Nix evaluation. Add automation clients
to the registry and an authorized group if needed; the binary cache is private
too. Loopback is always allowed. Use individual addresses, including IPv6 where
used, not the whole Tailscale range. An empty private group list allows only
loopback on private sites. Update the inventory if a device is re-enrolled with
new addresses.

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
