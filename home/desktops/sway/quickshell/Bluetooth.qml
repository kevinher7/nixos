import QtQuick
import Quickshell.Bluetooth as Bt

Pill {
    id: root

    readonly property bool bluetoothEnabled: Bt.Bluetooth.adapters.values.some(adapter => adapter.enabled)
    readonly property bool connected: Bt.Bluetooth.devices.values.some(device => device.connected)

    icon: {
        if (!root.bluetoothEnabled)
            return "󰂲";
        return root.connected ? "󰂱" : "󰂯";
    }

    iconColor: root.bluetoothEnabled ? Theme.light.accent : Theme.dark.muted
}
