import Quickshell
import QtQuick

// qmllint disable uncreatable-type
PanelWindow {
    // qmllint enable uncreatable-type
    id: bar

    required property var modelData

    screen: modelData
    color: "transparent"
    implicitHeight: Theme.barHeight
    exclusiveZone: height

    anchors {
        top: true
        left: true
        right: true
    }

    Clock {
        anchors.centerIn: parent
    }

    Row {
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: Theme.spacing
        }

        spacing: Theme.spacing

        Audio {}
        Microphone {}
        Bluetooth {}
        Internet {}
        Battery {}
    }

    Workspaces {
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: Theme.spacing
        }
        outputName: bar.screen.name
    }
}
