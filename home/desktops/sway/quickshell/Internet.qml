import QtQuick
import Quickshell.Networking

Pill {
    id: root

    readonly property var ethernet: Networking.devices.values.find(device => device.type === DeviceType.Wired && device.connected) ?? null
    readonly property var wifi: Networking.devices.values.find(device => device.type === DeviceType.Wifi && device.connected) ?? null
    readonly property var wifiNetwork: wifi?.networks.values.find(network => network.connected) ?? null
    readonly property real signalStrength: wifiNetwork?.signalStrength ?? 0

    icon: {
        if (root.ethernet)
            return "󰍹";
        if (!root.wifiNetwork)
            return "󰤭";
        if (root.signalStrength >= 0.75)
            return "󰤨";
        if (root.signalStrength >= 0.5)
            return "󰤥";
        if (root.signalStrength >= 0.25)
            return "󰤢";
        return "󰤟";
    }

    iconColor: root.ethernet || root.wifiNetwork ? Theme.light.accent : Theme.dark.muted
}
