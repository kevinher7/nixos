import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property color iconColor: Theme.blue
    property int maxLabelWidth: 400

    implicitWidth: row.implicitWidth + 22
    implicitHeight: 32
    radius: height / 2
    color: Theme.background

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 7

        Text {
            text: root.icon
            color: root.iconColor
            font.family: Theme.iconFontFamily
            font.pixelSize: Theme.fontSize
        }

        Text {
            text: root.label
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            elide: Text.ElideRight
            Layout.maximumWidth: root.maxLabelWidth
            visible: root.label !== ""
        }
    }
}
