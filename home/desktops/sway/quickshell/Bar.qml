import Quickshell
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: bar

    required property var modelData

    screen: modelData
    color: "transparent"
    implicitHeight: 40
    exclusiveZone: 40

    anchors {
        top: true
        left: true
        right: true
    }

    Pill {
        anchors.centerIn: parent
        icon: ""
        label: "9:11"
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 8
            rightMargin: 8
        }

        spacing: 8

        Workspaces {
            Layout.fillHeight: true
            outputName: bar.screen.name
        }

        Item {
            Layout.fillWidth: true
        }

        SystemStatus {
            Layout.fillHeight: true
        }

        StatusSeparator {}

        NetworkStatus {
            Layout.fillHeight: true
        }

        StatusSeparator {}

        BluetoothStatus {
            Layout.fillHeight: true
        }

        StatusSeparator {}

        ClockStatus {
            Layout.fillHeight: true
        }
    }
}
