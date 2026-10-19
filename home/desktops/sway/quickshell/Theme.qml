pragma Singleton

import Quickshell
import QtQuick

Singleton {
    component Palette: QtObject {
        required property color background
        required property color muted
        required property color foreground
        required property color urgent
        required property color active
        required property color accent
    }

    readonly property Palette dark: Palette {
        id: darkTheme

        background: "#000000"
        muted: Quickshell.env("QS_BASE03")
        foreground: Quickshell.env("QS_BASE05")
        urgent: Quickshell.env("QS_BASE08")
        active: Quickshell.env("QS_BASE0C")
        accent: Quickshell.env("QS_BASE0D")
    }

    readonly property Palette light: Palette {
        background: darkTheme.foreground
        muted: darkTheme.muted
        foreground: darkTheme.background
        urgent: darkTheme.urgent
        active: darkTheme.active
        accent: darkTheme.accent
    }

    readonly property color background: darkTheme.background
    readonly property color muted: darkTheme.muted
    readonly property color foreground: darkTheme.foreground
    readonly property color urgent: darkTheme.urgent
    readonly property color active: darkTheme.active
    readonly property color accent: darkTheme.accent

    readonly property string fontFamily: Quickshell.env("QS_FONT_FAMILY")
    readonly property string iconFontFamily: Quickshell.env("QS_ICON_FONT_FAMILY")
    readonly property int fontSize: parseInt(Quickshell.env("QS_FONT_SIZE"), 10)

    readonly property real barHeight: fontSize * 10 / 3
    readonly property real controlHeight: barHeight * 0.8
    readonly property real spacing: barHeight * 0.2
}
