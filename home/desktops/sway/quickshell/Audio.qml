import QtQuick
import Quickshell.Services.Pipewire

Pill {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool available: sink !== null && sink.ready && sink.audio !== null
    readonly property real volume: available ? sink.audio.volume : 0
    readonly property bool muted: !available || sink.audio.muted

    PwObjectTracker {
        objects: [root.sink]
    }

    icon: {
        if (root.muted || root.volume === 0)
            return "󰖁";
        if (root.volume < 0.33)
            return "󰕿";
        if (root.volume < 0.66)
            return "󰖀";
        return "󰕾";
    }

    iconColor: root.muted || root.volume === 0 ? Theme.dark.muted : Theme.light.accent
}
