import Quickshell
import QtQuick

Item {
    implicitWidth: clockText.implicitWidth
    implicitHeight: 30

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Text {
        id: clockText

        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, "ddd, MMM dd - HH:mm")
        color: Theme.blue
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.bold: true
    }
}
