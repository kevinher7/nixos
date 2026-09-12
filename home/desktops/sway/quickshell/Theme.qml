pragma Singleton

import Quickshell
import QtQuick

Singleton {
    function environment(name, fallback) {
        const value = Quickshell.env(name)
        return value === null || value === undefined || value === "" ? fallback : value
    }

    readonly property color background: environment("QS_BASE00", "#1b1b23")
    readonly property color muted: environment("QS_BASE03", "#444b6a")
    readonly property color foreground: environment("QS_BASE05", "#f4ded1")
    readonly property color urgent: environment("QS_BASE08", "#7e93a6")
    readonly property color yellow: environment("QS_BASE0A", "#e0af68")
    readonly property color cyan: environment("QS_BASE0C", "#0db9d7")
    readonly property color blue: environment("QS_BASE0D", "#7aa2f7")

    readonly property string fontFamily: environment("QS_FONT_FAMILY", "JetBrains Mono")
    readonly property int fontSize: parseInt(environment("QS_FONT_SIZE", "12"), 10)
}
