# Qutebrowser

Configuration lives in [`home/programs/qutebrowser/default.nix`](../home/programs/qutebrowser/default.nix).
Edit Nix, not the generated `config.py`.

- [Nix configuration guide and option references](qutebrowser-configuration.md)
- [Everyday keys and commands](qutebrowser-usage.md)

The notes below cover the existing platform choices and compatibility checks.

Both Linux laptops enable Widevine through the nixpkgs qutebrowser package.
Only `widevine-cdm` is newly permitted as unfree software. Restart qutebrowser
after rebuilding so the new package and Qt flags take effect.

## macOS

kebee runs the upstream release DMG instead of the nixpkgs build. The nixpkgs
app hands off to `python3.14`, so AeroSpace never registers its window. The
upstream app is a native binary with bundle id `org.qutebrowser.qutebrowser`,
which AeroSpace manages like any other app. The Homebrew cask is disabled for
failing Gatekeeper, so Nix fetches the same DMG. Bump `version` and `hash` in
`home/programs/qutebrowser/default.nix` to update it.

Home Manager writes the config to `~/.qutebrowser`. Widevine and the Bitwarden
bindings are Linux only.

## Bitwarden

The Bitwarden bindings exist on the Linux laptops only.
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

Keep qutebrowser's built-in Google user-agent handling enabled. Google sign-in
worked in a temporary default profile, while the configured profile with a
Firefox 135 override failed. The configuration no longer skips `ua-google`
or overrides the Google Accounts user agent. Sign-in with the remaining
custom settings still needs verification.

After rebuilding, restart qutebrowser to clear the removed runtime overrides.
Related upstream reports are in
[issue #5182](https://github.com/qutebrowser/qutebrowser/issues/5182).

## Playback checks

Qutebrowser 3.7.0 with QtWebEngine 6.11.2 and Widevine 4.10.3050.0
successfully created Widevine media keys for H.264/AAC in a temporary profile.
This checks CDM initialization, not license acquisition or video playback.

Widevine support does not establish that a streaming service accepts the
browser. Before replacing Zen, test Netflix and another DRM service, then
check audio, fullscreen, and login persistence after restarting the browser.
Compare memory with the same tabs open in both browsers.

The configuration keeps Zen enabled on kebean while these checks are pending.
