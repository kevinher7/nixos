# Qutebrowser on NixOS

Both laptop hosts enable Widevine through the nixpkgs qutebrowser package.
Only `widevine-cdm` is newly permitted as unfree software. Restart qutebrowser
after rebuilding so the new package and Qt flags take effect.

## Bitwarden

Configure the CLI before its first login:

```sh
bw config server https://vault.beanhaven.net
bw login
```

The browser extension and CLI have separate login sessions. If `bw config server`
still reports `https://vault.uribogoat.duckdns.org`, back up the encrypted CLI
data and run `bw logout` before changing the server. The old hostname does not
match the server's TLS certificate. The CLI needs a new login after this change.
Use `bw sync` to refresh the vault after unlocking it.
Login performs an initial sync. The userscript reads the local vault and does
not pull changes from other clients before filling.

Focus the username field and use `,u`. Focus the password field and use `,p`.
For multi-page logins, advance to the password page before using `,p`.
The script types into the focused field without checking its type.

| Binding | Action |
| --- | --- |
| `,p` | Fill only the password |
| `,P` | Fill only the password and copy TOTP to the clipboard |
| `,u` | Fill only the username |
| `,s` | Fill only the password |
| `,t` | Fill only the TOTP code |

The script prompts through rofi and caches its unlocked session in the Linux
keyring for 15 minutes. It matches the page's domain against Bitwarden login
URIs. Use separate username and password bindings for multi-page logins.

If filling fails, check `:messages` and `bw status`. A locked vault should
trigger a password prompt. An unauthenticated CLI needs `bw login` first.
`request_key: Required key not available` means the script has no cached
session key yet. The script then prompts for the master password.
The packaged userscript is patched to accept entries without a `totp` field.

## Google sign-in

Google Accounts uses a Firefox 135 user agent scoped to
`https://accounts.google.com/*`. This replaces qutebrowser's built-in
`ua-google` quirk. Other sites keep their normal user agent.

This is a workaround reported in
[upstream issue #5182](https://github.com/qutebrowser/qutebrowser/issues/5182).
Successful sign-in still needs verification with the affected account.
Try a direct login at <https://accounts.google.com/> before an OAuth login
from another site. To compare with the default identity for the current
session, run `:config-unset --temp -u https://accounts.google.com/* content.headers.user_agent`.
`:config-source` restores the configured identity.

## Playback checks

Qutebrowser 3.7.0 with QtWebEngine 6.11.2 and Widevine 4.10.3050.0
successfully created Widevine media keys for H.264/AAC in a temporary profile.
This checks CDM initialization, not license acquisition or video playback.

Widevine support does not establish that a streaming service accepts the
browser. Before replacing Zen, test Netflix and another DRM service, then
check audio, fullscreen, and login persistence after restarting the browser.
Compare memory with the same tabs open in both browsers.

The configuration keeps Zen enabled on kebean while these checks are pending.
