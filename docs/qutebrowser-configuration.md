# Configuring qutebrowser with Nix

## Where things live

[`home/programs/qutebrowser/default.nix`](../home/programs/qutebrowser/default.nix) is the
source of truth. Its `myPrograms.qutebrowser.enable` switch enables the
Home Manager configuration. The switch is declared and the module imported
in [`home/programs/default.nix`](../home/programs/default.nix).

| Host | Home profile | Package |
| --- | --- | --- |
| `beans-btw` | `home/hosts/chromebook.nix` | nixpkgs with Widevine |
| `kebean` | `home/hosts/dell.nix` | nixpkgs with Widevine |
| `kebee` | `home/hosts/macbook.nix` | Upstream arm64 DMG, currently 3.7.0 |

Home Manager generates `~/.config/qutebrowser/config.py` on Linux and
`~/.qutebrowser/config.py` on macOS. These are Nix-managed files. Do not use
`:config-edit` or overwrite them with `:config-write-py`.

`loadAutoconfig = false` means saved interactive settings are not loaded at
startup. Keep changes in Nix rather than enabling a second configuration source.

## The complete options reference

The file inside qutebrowser that defines settings is
[`qutebrowser/config/configdata.yml`](https://github.com/qutebrowser/qutebrowser/blob/v3.7.0/qutebrowser/config/configdata.yml).
It includes descriptions, defaults, types, valid values, and URL-pattern support.
It is reference data, not a file to edit. The link matches the current macOS
package. Check `:version` on each host before consulting versioned sources.

In the installed macOS app, its relative path is
`qutebrowser.app/Contents/Resources/qutebrowser/config/configdata.yml`.
To read the Nix-managed copy from this repo:

```sh
package=$(nix eval --raw .#darwinConfigurations.kebee.config.home-manager.users.beellm.programs.qutebrowser.package.outPath)
less "$package/Applications/qutebrowser.app/Contents/Resources/qutebrowser/config/configdata.yml"
```

The package must already be built for that path to exist.

For everyday lookup, prefer the installed browser's help. It matches the
running version, unlike the website, which can describe a newer release.

| Lookup | Browser command |
| --- | --- |
| All settings with documentation | `:help settings` |
| A particular setting | `:help tabs.position` |
| Interactive settings list | `:set` |
| All commands | `:help commands` |
| Command syntax | `:help :set` |
| Versions and configuration paths | `:version` |
| Current customized values | `:config-diff` |

If the file you remember is an annotated `config.py` containing every option,
qutebrowser can export that too. Run this inside the browser:

```text
:config-write-py --defaults /tmp/qutebrowser-defaults.py
```

This is a disposable reference, not our configuration. Do not source it or copy
every default into Nix. Choose only the settings you want to change. If the
export already exists, remove it or choose another filename rather than
overwriting the managed config.

Sources: [configuration guide](https://qutebrowser.org/doc/help/configuring.html),
[export command](https://qutebrowser.org/doc/help/commands.html#config-write-py),
[online settings reference](https://qutebrowser.org/doc/help/settings.html).

## Translate options into Nix

Use these fields inside the existing `programs.qutebrowser` block:

| What you want | Home Manager field |
| --- | --- |
| Browser settings | `settings` |
| Site-specific settings | `perDomainSettings` |
| Keys that run commands | `keyBindings.<mode>` |
| Keys that act as other keys | `keyMappings` |
| Search shortcuts | `searchEngines` |
| Command aliases | `aliases` |
| Declarative quickmarks | `quickmarks` |
| Greasemonkey scripts | `greasemonkey` |

For example, these are Nix settings, not Python:

```nix
programs.qutebrowser = {
  settings = {
    tabs.position = "left";
    scrolling.smooth = true;
    url.start_pages = ["https://duckduckgo.com/"];
  };

  perDomainSettings."https://example.com/*" = {
    colors.webpage.darkmode.enabled = false;
  };

  keyBindings.normal.",r" = "config-source";
};
```

These examples are not enabled. Add chosen entries to the existing blocks
rather than creating duplicate attribute definitions.

Option names keep their dots. Strings use double quotes, booleans are `true`
and `false`, lists use `[ ... ]`, and null is `null`. Only settings marked as
supporting URL patterns can go in `perDomainSettings`. Keep patterns quoted.
Use `keyBindings` rather than modifying `settings.bindings.commands` so default
bindings remain available.

The pinned Home Manager module flattens nested attribute sets into dotted
option names. A qutebrowser dictionary value is not always representable as a
nested Nix set. In particular, `tabs.padding.top` is not a setting. This is why
the current padding dictionary lives in `extraConfig`.

`extraConfig` is raw Python despite being written inside a Nix string. Keep it
as a last resort. Use `perDomainSettings` for site-specific settings instead.

The implementation details above come from the
[pinned Home Manager module](https://github.com/nix-community/home-manager/blob/ab97a5d09e0f2aa7339cfd35ec5824fd6653e27c/modules/programs/qutebrowser.nix).
The [Home Manager option reference](https://nix-community.github.io/home-manager/options/home-manager/programs/qutebrowser.html)
is useful for browsing but may be newer than `flake.lock`.

## Try, keep, apply

1. Read the setting's help and check its allowed values.
2. Try a temporary value, for example `:set --temp tabs.position left`.
3. If you want to keep it, add `tabs.position = "left";` to Nix `settings`.
4. Rebuild the host from the repository root.
5. Run `:config-source` to reload the generated file and check `:messages`.

```sh
sudo darwin-rebuild switch --flake .#kebee
```

On Linux, use the relevant hostname:

```sh
sudo nixos-rebuild switch --flake .#kebean
```

Home Manager attempts to reload a running Linux browser when the generated file
changes. Reload manually on macOS. Restart for package changes or settings whose
help requires it. `:config-source` only reloads the installed file. It does not
evaluate Nix or apply unbuilt edits.

Reloading does not necessarily clear experiments or settings removed from Nix.
Restart for a clean check. `:config-source --clear` clears current settings
before loading, so use it only when you intend to discard session changes.

## Existing choices to account for

- Sessions restore automatically. Cookies persist and accept all cookies.
- Webpage dark mode is forced, with images excluded from inversion.
- Canvas reading and geolocation are disabled. Clipboard access is allowed.
  These choices can affect website behavior.
- Content blocking is enabled. Inspect `:messages` before assuming a broken
  website needs weaker privacy settings globally.
- Default font size is forced to `10pt`, with `12pt` tab labels.
- The Gruvbox dark palette lives in
  [`home/programs/qutebrowser/theme.nix`](../home/programs/qutebrowser/theme.nix).
  It sets browser colors through Home Manager and disables the qutebrowser
  Stylix target on Linux and macOS.
- Search shortcuts are `g` for Google, `k` for Kagi, and `n` for MyNixOS.
  Unprefixed searches use DuckDuckGo.
- Bitwarden integration is Linux only. Google sign-in uses the built-in
  user-agent handling. See [the existing compatibility notes](qutebrowser.md).

Home Manager manages quickmarks, including `yt` for YouTube. Add quickmarks to
`programs.qutebrowser.quickmarks` in Nix rather than editing them at runtime.
