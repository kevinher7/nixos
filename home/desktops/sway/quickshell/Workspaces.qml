pragma ComponentBehavior: Bound

import Quickshell.I3
import QtQuick

Rectangle {
    id: root

    implicitWidth: workspaceRow.implicitWidth + Theme.spacing * 2
    implicitHeight: Theme.controlHeight
    radius: height / 2
    color: Theme.dark.background

    Row {
        id: workspaceRow

        anchors.centerIn: parent
        height: root.height

        Repeater {
            model: 9

            delegate: Item {
                id: workspace

                required property int index

                readonly property int number: index + 1
                readonly property var swayWorkspace: I3.workspaces.values.find(candidate => candidate.number === number) ?? null
                readonly property bool activeOnAnyOutput: swayWorkspace?.active ?? false
                readonly property color indicatorColor: swayWorkspace?.urgent
                    ? Theme.dark.urgent
                    : swayWorkspace?.focused
                        ? Theme.dark.active
                        : swayWorkspace !== null
                            ? Theme.dark.accent
                            : Theme.dark.muted

                width: Math.round(Theme.fontSize * 1.25)
                height: workspaceRow.height

                Rectangle {
                    x: Math.round((parent.width - width) / 2)
                    y: Math.round((parent.height - height) / 2)
                    width: Math.round(Theme.fontSize * (workspace.activeOnAnyOutput ? 0.75 : 0.5))
                    height: width
                    radius: width / 2
                    color: workspace.activeOnAnyOutput ? "transparent" : workspace.indicatorColor
                    border.color: workspace.indicatorColor
                    border.width: workspace.activeOnAnyOutput ? 2 : 0
                    opacity: workspace.swayWorkspace !== null ? 1 : 0.35
                }

                TapHandler {
                    onTapped: {
                        if (workspace.swayWorkspace !== null)
                            workspace.swayWorkspace.activate();
                        else
                            I3.dispatch(`workspace number ${workspace.number}`);
                    }
                }
            }
        }
    }
}
