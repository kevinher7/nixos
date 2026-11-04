# Private and shared websites

`myHomelab.webAccess` restricts nginx websites by device IP address. Private
clients can reach every website. Each shared host adds its own guest groups.
New websites stay private. Vaultwarden's `/admin` prefix always stays private.

Device inventory lives in `modules/devices/inventory.nix`, shared by NixOS
and Darwin configurations. Devices are nested under the fixed `private` and
`vaultGuests` groups defined in `modules/devices/default.nix`. Each device maps
directly to a nonempty list of Tailscale IPv4 and IPv6 addresses:

```nix
myDevices.devices.private.newPhone = [
  "100.64.0.10"
  "fd7a:115c:a1e0::10"
];
```

Personal computers, the server, and the Pixel 9a belong to `private`.
`njqm10` belongs to `vaultGuests`. To place a device in multiple groups, list
its addresses under each group. Registry names are local configuration labels,
not Tailscale tags or authenticated usernames.

Website policy stays in `hosts/server/default.nix`:

```nix
webAccess = {
  enable = true;
  privateGroups = ["private"];
  sharedHosts."vault.${config.myVars.domain}".groups = ["vaultGuests"];
};
```

Unknown groups fail option validation in both device entries and website
policies. Add automation clients to the registry and an
authorized group if needed; the binary cache is private
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

## Vaultwarden admin access

The admin panel requires `vaultwarden_admin_token` in
`secrets/hosts/uribo-btw.yaml`. Store an Argon2id PHC hash there, not the
admin password. Generate it interactively on kebean:

```sh
nix shell nixpkgs#vaultwarden --command vaultwarden hash
```

Save the password in your password manager. From this repository on kebean,
open the encrypted host secrets with your passphrase-protected admin key:

```sh
sops secrets/hosts/uribo-btw.yaml
```

Add `vaultwarden_admin_token` with the complete generated `$argon2id$…`
string as a single quoted YAML value. Do not include the `ADMIN_TOKEN=`
prefix. Commit the encrypted file to the configuration PR before merging
or deploying; activation requires this key to exist.

Sops-nix renders a root-only environment file at runtime, outside the Nix
store. Vaultwarden receives the hash through its built-in `environmentFile`
option and restarts when the secret changes. Never place the password or
hash directly in the Nix configuration.

After deploying, open <https://vault.beanhaven.net/admin> from a private
device and sign in with the original password. In **Users**, invite your
friend's email address. Without SMTP, send them
<https://vault.beanhaven.net/#/signup> and have them register with that exact
email address and their own master password. Public registration stays disabled.

Settings saved through the admin panel take precedence over environment
variables. Avoid saving an admin token override there, so sops remains the
source of the hash. For rotation, `nix run .#rotate-secrets` includes
`vaultwarden_admin_token` and asks for a newly generated hash.
