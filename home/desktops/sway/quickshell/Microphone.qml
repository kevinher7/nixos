import QtQuick
import Quickshell.Services.Pipewire

Pill {
    id: root

    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property bool available: source !== null && source.ready && source.audio !== null
    readonly property bool muted: !available || source.audio.muted
    readonly property bool recording: available && linkTracker.linkGroups.some(link => link.state === PwLinkState.Active)

    PwNodeLinkTracker {
        id: linkTracker

        node: root.source
    }

    PwObjectTracker {
        objects: [root.source, ...linkTracker.linkGroups]
    }

    icon: root.muted ? "󰍭" : "󰍬"
    label: root.available ? Math.round(root.source.audio.volume * 100) + "%" : "Unavailable"
    iconColor: root.recording ? Theme.dark.active : root.muted ? Theme.dark.muted : Theme.dark.foreground
}
