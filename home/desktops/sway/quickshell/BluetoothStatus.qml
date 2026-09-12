import Quickshell.Bluetooth
import QtQuick

Item {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var connectedDevices: Bluetooth.devices.values
    readonly property string statusText: {
        if (adapter === null)
            return ""

        if (!adapter.enabled)
            return "BT: off"

        if (connectedDevices.length === 0)
            return "BT: on"

        const names = connectedDevices.map(device => {
            const battery = device.batteryAvailable
                ? " " + Math.round(device.battery * 100) + "%"
                : ""
            return device.name + battery
        })

        return "BT: " + names.join(", ")
    }

    implicitWidth: bluetoothText.implicitWidth
    implicitHeight: 30

    Text {
        id: bluetoothText

        anchors.centerIn: parent
        text: root.statusText
        color: root.connectedDevices.length > 0
            ? Theme.cyan
            : root.adapter !== null && root.adapter.enabled
                ? Theme.blue
                : Theme.muted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.bold: true
    }
}
