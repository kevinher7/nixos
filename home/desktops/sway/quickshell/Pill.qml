import QtQuick

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property color iconColor: Theme.light.accent

    implicitWidth: row.implicitWidth + Theme.spacing * 2
    implicitHeight: Theme.controlHeight
    radius: height / 2
    color: Theme.dark.background

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.spacing

        Text {
            text: root.icon
            color: root.iconColor
            font.family: Theme.iconFontFamily
            font.pixelSize: Theme.fontSize
            font.bold: true
        }

        Text {
            text: root.label
            color: Theme.dark.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.bold: true
            visible: root.label !== ""
        }
    }
}
