import Quickshell.Networking
import QtQuick

Item {
    id: root

    readonly property var connectedDevice: Networking.devices.values.find(device => device.connected)
    readonly property var connectedNetwork: connectedDevice === undefined
        ? undefined
        : connectedDevice.networks.values.find(network => network.connected)
    readonly property bool isWifi: connectedDevice !== undefined && connectedDevice.type === DeviceType.Wifi
    readonly property string statusText: {
        if (connectedDevice === undefined)
            return Networking.wifiEnabled ? "Net: offline" : "Net: Wi-Fi off"

        if (!isWifi)
            return "Net: wired"

        if (connectedNetwork === undefined)
            return "Net: Wi-Fi"

        const strength = Math.round(connectedNetwork.signalStrength * 100)
        return "Net: " + connectedNetwork.name + " " + strength + "%"
    }

    implicitWidth: networkText.implicitWidth
    implicitHeight: 30

    Text {
        id: networkText

        anchors.centerIn: parent
        text: root.statusText
        color: root.connectedDevice === undefined ? Theme.muted : Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.bold: true
    }
}
