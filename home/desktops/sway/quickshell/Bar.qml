import Quickshell
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: bar

    required property var modelData

    screen: modelData
    color: Theme.background
    implicitHeight: 30
    exclusiveZone: 30

    anchors {
        top: true
        left: true
        right: true
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
