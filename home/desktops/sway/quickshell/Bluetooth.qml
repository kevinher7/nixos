import QtQuick
import Quickshell.Bluetooth as Bt

Pill {
    id: root

    readonly property bool bluetoothEnabled: Bt.Bluetooth.adapters.values.some(adapter => adapter.enabled)
    readonly property var connectedDevices: Bt.Bluetooth.devices.values.filter(device => device.connected)
    readonly property bool connected: connectedDevices.length > 0

    icon: {
        if (!root.bluetoothEnabled)
            return "󰂲";
        return root.connected ? "󰂱" : "󰂯";
    }

    label: root.connected
        ? root.connectedDevices.map(device => device.name || device.address).join(", ")
        : root.bluetoothEnabled ? "On" : "Off"
    iconColor: root.bluetoothEnabled ? Theme.light.accent : Theme.dark.muted
}
