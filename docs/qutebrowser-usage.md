# Getting used to qutebrowser

## Modes first

Normal mode treats keys as browser commands. Insert mode sends typing to a
webpage input. Press `i` to enter insert mode and `Escape` to return to normal.
If a shortcut appears to type into a form, check the mode first.

`f` enters hint mode. Type the letters shown over a link to follow it.
`F` opens the hinted link in a new tab. `Escape` cancels hints.

`Ctrl-v` enters passthrough mode for sites with their own keyboard shortcuts.
`Shift-Escape` leaves passthrough mode with the upstream default bindings.

## Keys worth learning first

These are upstream defaults unless noted. Key chains such as `gg` mean press
the keys in sequence, not together. Uppercase letters mean Shift.

| Keys | Action |
| --- | --- |
| `o`, `O` | Open a URL or search, in this tab or a new tab |
| `go`, `gO` | Edit the current URL, opening here or in a new tab |
| `j`, `k`, `h`, `l` | Scroll down, up, left, right |
| `gg`, `G` | Go to the top or bottom |
| `H`, `L` | Back or forward |
| `J`, `K` | Previous or next tab |
| `d`, `u` | Close a tab or undo closing it |
| `r`, `R` | Reload or reload without cache |
| `/`, `n`, `N` | Find text, next match, previous match |
| `yy` | Copy the current URL |
| `pp`, `Pp` | Open the clipboard URL here or in a new tab |
| `+`, `-`, `=` | Zoom in, zoom out, reset zoom |
| `v` | Enter caret mode for keyboard text navigation |
| `:` | Enter a command, with Tab completion |
| `Ctrl-Tab` | Last focused tab, configured in this repo |

The repo also maps `!`, `"`, `#`, `$`, `%`, `&`, `'`, `(`, `)` to tabs
1 through 9. These are literal characters, not assumed US keyboard positions.

To use a search shortcut, type `o`, then `g qutebrowser`, then Enter.
Use `k` for Kagi or `n` for MyNixOS in the same way.

## Commands to keep nearby

| Command | Purpose |
| --- | --- |
| `:help` | Open installed documentation |
| `:bind` | Inspect bindings in the current configuration |
| `:help :hint` | Learn hint targets and options |
| `:bookmark-add` | Bookmark the current page |
| `:bookmark-load` | Pick a saved bookmark |
| `:quickmark-load` | Open a named quickmark |
| `:session-save work` | Save a named set of tabs |
| `:session-load work` | Load that session |
| `:download` | Download the current page |
| `:adblock-update` | Refresh blocking lists |
| `:messages` | Read errors and recent messages |
| `:version` | Check versions and filesystem paths |

Sessions restore automatically in this repo. Named sessions are useful when
you want to keep a particular set of tabs independently of the next startup.

Open YouTube with `:quickmark-load yt`, or press `b`, type `yt`, then Enter.
Home Manager manages quickmarks, so add new ones in Nix rather than using
`:quickmark-save`.

On Linux, focus the username input and press `,s` to fill the username and
password. This assumes Tab moves focus to the password input. For multi-page
logins, use `,u` on the username page and `,p` on the password page. The
Bitwarden userscript types into the focused field without checking its type.
Setup and the other bindings are in the
[Bitwarden notes](qutebrowser.md#bitwarden).

## Play videos in mpv

Press `,m` to open the current page in mpv, or `,M` to choose a video link
with hints. Both shortcuts work on Linux and macOS. The Nix mpv package
includes `yt-dlp` for YouTube and other supported sites.

Pause playback in the browser before opening mpv to avoid playing the video
twice. The shortcuts leave the browser tab open and start a separate mpv
window. They do not transfer the playback position or browser login session.

While a video plays in a visible mpv window, mpv inhibits idle locking on Sway.
Pausing or closing mpv allows the normal idle timeout again. Fullscreen is
not required. This does not change idle locking for videos inside qutebrowser.

DRM-protected services such as dAnime still need browser playback. These
shortcuts do not transfer Widevine playback to mpv.

## Learn without losing track of changes

Start with opening pages, hints, tabs, and search. Leave unfamiliar bindings
at their defaults until you know what you want to replace.

Use `:help <setting>` and `:set --temp <setting> <value>` for experiments.
Keep anything you like in [Nix configuration](qutebrowser-configuration.md),
not in the generated Python file. Saved `:set` and `:bind` changes do not load
on the next startup with this repo's `loadAutoconfig = false`.

For a website that behaves differently, compare normal and insert mode first,
then inspect `:messages`. Check scoped dark-mode or content settings before
changing them globally. A private window is not a clean configuration test.

References: [upstream quickstart](https://www.qutebrowser.org/quickstart.html),
[default key bindings](https://github.com/qutebrowser/qutebrowser/blob/v3.7.0/qutebrowser/config/configdata.yml),
[command reference](https://qutebrowser.org/doc/help/commands.html).
