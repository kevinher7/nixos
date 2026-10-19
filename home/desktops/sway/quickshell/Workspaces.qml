pragma ComponentBehavior: Bound

import Quickshell.I3
import QtQuick

Item {
    id: root

    required property string outputName

    implicitWidth: workspaceRow.implicitWidth
    implicitHeight: Theme.controlHeight

    Row {
        id: workspaceRow

        height: parent.height
        spacing: Theme.spacing

        Repeater {
            model: 9

            delegate: Text {
                id: workspace

                required property int index

                readonly property int number: index + 1
                readonly property var swayWorkspace: I3.workspaces.values.find(candidate => candidate.number === number)
                readonly property bool activeOnOutput: swayWorkspace !== undefined
                    && swayWorkspace.active
                    && swayWorkspace.monitor !== null
                    && swayWorkspace.monitor.name === root.outputName

                height: workspaceRow.height
                text: number
                color: swayWorkspace?.urgent
                    ? Theme.urgent
                    : activeOnOutput
                        ? Theme.active
                        : swayWorkspace !== undefined
                            ? Theme.accent
                            : Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.bold: true
                verticalAlignment: Text.AlignVCenter

                TapHandler {
                    onTapped: I3.dispatch(`workspace number ${workspace.number}`)
                }
            }
        }
    }
}
