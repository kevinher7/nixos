# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
import os
import re
import subprocess

from libqtile import hook, bar, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

mod = "mod4"
terminal = guess_terminal()

# The qtile config dir is symlinked from the repo, so realpath lands in the
# repo checkout and the wallpaper path works without hardcoding $HOME paths.
WALLPAPER = os.path.join(
    os.path.dirname(os.path.realpath(__file__)),
    "../../../assets/wallpapers/girl-reading-book.png",
)


def set_wallpaper():
    """Apply the wallpaper for the active backend.

    On X11 the root pixmap is lost every time the screen is resized (monitor
    hotplug/rearrange), and on Wayland nothing sets a wallpaper by itself, so
    this runs on startup and on every screen change.
    """
    if qtile.core.name == "wayland":
        # Respawn so newly connected outputs get covered too
        subprocess.run(["pkill", "-x", "swaybg"], check=False)
        subprocess.Popen(["swaybg", "-i", WALLPAPER, "-m", "fill"])
    else:
        subprocess.Popen(["xwallpaper", "--zoom", WALLPAPER])


def arrange_x11_outputs():
    """Lay out all connected outputs side by side at their preferred mode.

    Only needed on the X11 backend; kanshi handles this on Wayland.
    """
    if qtile.core.name != "x11":
        return

    result = subprocess.run(["xrandr", "--query"], capture_output=True, text=True)
    connected = [
        line.split()[0] for line in result.stdout.splitlines() if " connected" in line
    ]
    if len(connected) < 2:
        return

    cmd = ["xrandr", "--output", connected[0], "--auto"]
    for previous, current in zip(connected, connected[1:]):
        cmd += ["--output", current, "--auto", "--right-of", previous]
    subprocess.run(cmd)


@hook.subscribe.startup_once
def autostart():
    # Using subprocess.Popen so it doesn't block Qtile startup
    subprocess.Popen(["pasystray"])
    subprocess.Popen(["fcitx5", "-d"])

    # Expose the display to dbus/systemd user services; without this kanshi's
    # ConditionEnvironment=WAYLAND_DISPLAY never passes. The explicit restart
    # covers the case where kanshi was skipped before the env was imported
    # (no-op where the kanshi unit doesn't exist, e.g. X11 sessions/hosts).
    subprocess.run(
        [
            "dbus-update-activation-environment",
            "--systemd",
            "WAYLAND_DISPLAY",
            "DISPLAY",
        ],
        check=False,
    )
    subprocess.run(["systemctl", "--user", "restart", "kanshi"], check=False)

    arrange_x11_outputs()
    set_wallpaper()


@hook.subscribe.screen_change
def reapply_wallpaper():
    set_wallpaper()


def find_wifi_interface():
    """Return the first wireless interface name (wlp2s0, wlp0s12f0, ...)."""
    try:
        return next(
            iface for iface in os.listdir("/sys/class/net") if iface.startswith("wl")
        )
    except StopIteration:
        return None


wifi_interface = find_wifi_interface()


def get_wifi_icon():
    if wifi_interface is None:
        return "󰤫"

    try:
        with open(f"/sys/class/net/{wifi_interface}/operstate") as f:
            if f.read().strip() != "up":
                return "󰤭"

        # Try using iwconfig for percentage-based quality
        result = subprocess.run(
            ["iwconfig", wifi_interface], capture_output=True, text=True
        )

        # Look for "Link Quality=67/70" or "Signal level=-45 dBm"
        quality_match = re.search(r"Link Quality=(\d+)/(\d+)", result.stdout)
        signal_match = re.search(r"Signal level=(-\d+) dBm", result.stdout)

        if quality_match:
            quality = int(quality_match.group(1))
            max_quality = int(quality_match.group(2))
            percentage = (quality / max_quality) * 100

            if percentage >= 75:
                return "󰤨"
            elif percentage >= 50:
                return "󰤥"
            elif percentage >= 25:
                return "󰤢"
            else:
                return "󰤟"

        elif signal_match:
            signal_dbm = int(signal_match.group(1))

            if signal_dbm >= -50:
                return "󰤨"
            elif signal_dbm >= -60:
                return "󰤥"
            elif signal_dbm >= -70:
                return "󰤢"
            else:
                return "󰤟"

        # Check if interface is up but not connected
        if "no wireless" in result.stdout.lower():
            return "󰤭"

        return "󰤭"

    except Exception:
        return "󰤫"


@lazy.function
def window_to_screen(qtile, direction=1):
    """Send the focused window to the group shown on the next/previous screen."""
    window = qtile.current_window
    if window is None:
        return
    index = (qtile.current_screen.index + direction) % len(qtile.screens)
    window.togroup(qtile.screens[index].group.name)


@lazy.function
def group_to_screen(qtile, direction=1):
    """Send the current group to the next/previous screen.

    Groups swap if the destination screen is occupied (built-in toscreen
    behaviour), so with two monitors this sends the workspace to the other
    monitor.
    """
    index = (qtile.current_screen.index + direction) % len(qtile.screens)
    qtile.current_group.toscreen(index)


keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key(
        [mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"
    ),
    Key(
        [mod, "shift"],
        "l",
        lazy.layout.shuffle_right(),
        desc="Move window to the right",
    ),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Multi-monitor control (xmonad-style mod+, / mod+.)
    # mod = focus monitor, mod+shift = send window, mod+control = send group
    Key([mod], "comma", lazy.prev_screen(), desc="Focus previous monitor"),
    Key([mod], "period", lazy.next_screen(), desc="Focus next monitor"),
    Key(
        [mod, "shift"],
        "comma",
        window_to_screen(direction=-1),
        desc="Send focused window to previous monitor",
    ),
    Key(
        [mod, "shift"],
        "period",
        window_to_screen(direction=1),
        desc="Send focused window to next monitor",
    ),
    Key(
        [mod, "control"],
        "comma",
        group_to_screen(direction=-1),
        desc="Send current group to previous monitor",
    ),
    Key(
        [mod, "control"],
        "period",
        group_to_screen(direction=1),
        desc="Send current group to next monitor",
    ),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key(
        [mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"
    ),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    Key(
        [mod],
        "t",
        lazy.window.toggle_floating(),
        desc="Toggle floating on the focused window",
    ),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    Key([mod], "b", lazy.spawn("qutebrowser")),
    Key([mod, "shift"], "f", lazy.spawn("pcmanfm")),
    Key([mod], "d", lazy.spawn("rofi -show drun")),
    Key([mod, "control"], "l", lazy.spawn("betterlockscreen -l dimblur")),
    # Show Windows Control
    Key([], "XF86LaunchA", lazy.spawn("rofi -show window"), desc="Show all windows"),
    # Brightness Control
    Key(
        [],
        "XF86MonBrightnessDown",
        lazy.spawn("light -U 10"),
        desc="Increase Brightness",
    ),
    Key(
        [],
        "XF86MonBrightnessUp",
        lazy.spawn("light -A 10"),
        desc="Decrease Brightness",
    ),
    # Audio Control
    Key(
        [],
        "XF86AudioRaiseVolume",
        lazy.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
        desc="Raise Volume",
    ),
    Key(
        [],
        "XF86AudioLowerVolume",
        lazy.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
        desc="Lower Volume",
    ),
    Key(
        [],
        "XF86AudioMute",
        lazy.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
        desc="Mute Volume",
    ),
]

# Add key bindings to switch VTs in Wayland.
# We can't check qtile.core.name in default config as it is loaded before qtile is started
# We therefore defer the check until the key binding is run by using .when(func=...)
for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )

groups = []
groups = [Group(i) for i in "1234"]

for i in groups:
    keys.extend(
        [
            # mod + group number = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc=f"Switch to group {i.name}",
            ),
            # mod + shift + group number = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc=f"Switch to & move focused window to group {i.name}",
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod + shift + group number = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )


layout_theme = {}

layouts = [
    # layout.Columns(border_focus_stack=["#d75f5f", "#8f3d3d"], border_width=4),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    layout.MonadTall(
        font="JetBrainsMono NF Bold",
        fontsize=10,
    ),
    layout.Max(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    layout.TreeTab(
        font="JetBrains Mono",
        fontsize=10,
        sections=["FIRST", "SECOND"],
        border_width=2,
        bg_color="1c1f24",
        active_bg="c678dd",
        active_fg="000000",
        inactive_bg="a9a1e1",
        inactive_fg="1c1f24",
        padding_left=0,
        padding_x=0,
        padding_y=5,
        section_top=10,
        section_bottom=20,
        level_shift=8,
        vspace=3,
        panel_width=200,
    ),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

colors = [
    "#084959",  # Panel Background Dark
    "#ffffff",  # Groub Box Font Color
    "#dc4c4c",  # Current Group Back
    "#d1af61",  # Text
    "#ffffff",  # Active Group Font
    "#562f46",  # Inactive Group Font
]

widget_defaults = dict(
    font="JetBrainsMono Nerd Font",
    fontsize=13,
    padding=5,
)
extension_defaults = widget_defaults.copy()


def make_bar_widgets(primary=False):
    """Fresh widget instances for one screen's bar.

    Widgets cannot be shared between bars, so each screen builds its own set.
    StatusNotifier must exist only once per session (it owns the watcher on
    the bus), so only the primary screen gets the tray.
    """
    widgets = [
        widget.CurrentLayout(
            **widget_defaults,
            background=colors[0],
        ),
        widget.GroupBox(
            disable_drag=True,
            rounded=False,
            font="JetBrainsMono NF Bold",
            fontsize=13,
            # padding = 5,
            padding_x=10,
            highlight_method="block",
            background=colors[0],
            foreground=colors[1],
            this_current_screen_border=colors[2],
            active=colors[-2],
            inactive=colors[-1],
        ),
        widget.Prompt(
            **widget_defaults,
            background=colors[0],
        ),
        widget.WindowName(
            **widget_defaults,
            background=colors[0],
            foreground=colors[3],
        ),
        # Wifi Widget
        widget.GenPollText(
            font="JetBrainsMono Nerd Font",
            fontsize=16,
            padding=16,
            align="center",
            background=colors[0],
            foreground=colors[2],
            func=lambda: get_wifi_icon(),
            update_interval=5,
        ),
    ]

    if primary:
        widgets.append(
            widget.StatusNotifier(
                font="JetBrainsMono Nerd Font",
                fontsize=13,
                padding=10,
                icon_theme="Papirus-Dark",
                background=colors[2],
            )
        )

    widgets.extend(
        [
            widget.Battery(
                font="JetBrainsMono Nerd Font Bold",
                fontsize=14,
                padding=4,
                align="center",
                background=colors[0],
                format="{char} {percent:1.0%}",
                charge_char="󰂄",
                discharge_char="󰁹",
                empty_char="󰂎",
                full_char="󰁹",
                unknown_char="󰂃",
                update_interval=60,
                charge_controller=lambda: (0, 95),
            ),
            # Volume
            # widget.GenPollText(
            #     font="JetBrainsMono Nerd Font",
            #     func=lambda: get_volume_icon(),
            #     fontsize=14,
            #     padding=8,
            #     align="center",
            #     background=colors[0],
            #     update_interval=0.3,
            # ),
            widget.Clock(
                **widget_defaults,
                background=colors[2],
                format="%Y-%m-%d %a %I:%M %p",
            ),
        ]
    )
    return widgets


# One entry per physical monitor: extra monitors used to get a bare Screen
# with no bar. Unused entries are ignored when fewer outputs are connected.
screens = [Screen(top=bar.Bar(make_bar_widgets(primary=i == 0), 24)) for i in range(2)]

# Drag floating layouts.
mouse = [
    Drag(
        [mod],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# xcursor theme (string or None) and size (integer) for Wayland backend
wl_xcursor_theme = None
wl_xcursor_size = 24

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
