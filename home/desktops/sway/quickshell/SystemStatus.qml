import Quickshell.Io
import QtQuick

Item {
    id: root

    property int cpuUsage: 0
    property int memoryUsage: 0
    property double lastCpuIdle: 0
    property double lastCpuTotal: 0

    implicitWidth: statusRow.implicitWidth
    implicitHeight: 30

    function updateCpu() {
        const cpuLine = cpuFile.text().split("\n")[0]
        const values = cpuLine.trim().split(/\s+/).slice(1).map(Number)
        if (values.length < 5)
            return

        const idle = values[3] + values[4]
        const total = values.reduce((sum, value) => sum + value, 0)
        const totalDelta = total - lastCpuTotal
        const idleDelta = idle - lastCpuIdle

        if (lastCpuTotal > 0 && totalDelta > 0)
            cpuUsage = Math.round((1 - idleDelta / totalDelta) * 100)

        lastCpuIdle = idle
        lastCpuTotal = total
    }

    function updateMemory() {
        const values = {}
        for (const line of memoryFile.text().split("\n")) {
            const match = line.match(/^(MemTotal|MemAvailable):\s+(\d+)/)
            if (match !== null)
                values[match[1]] = Number(match[2])
        }

        if (values.MemTotal > 0)
            memoryUsage = Math.round((1 - values.MemAvailable / values.MemTotal) * 100)
    }

    FileView {
        id: cpuFile

        path: "/proc/stat"
        onLoaded: root.updateCpu()
    }

    FileView {
        id: memoryFile

        path: "/proc/meminfo"
        onLoaded: root.updateMemory()
    }

    Timer {
        interval: 2000
        running: true
        repeat: true

        onTriggered: {
            cpuFile.reload()
            memoryFile.reload()
        }
    }

    Row {
        id: statusRow

        height: parent.height
        spacing: 8

        Text {
            height: parent.height
            text: "CPU: " + root.cpuUsage + "%"
            color: Theme.yellow
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.bold: true
            verticalAlignment: Text.AlignVCenter
        }

        StatusSeparator {
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            height: parent.height
            text: "Mem: " + root.memoryUsage + "%"
            color: Theme.cyan
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.bold: true
            verticalAlignment: Text.AlignVCenter
        }
    }
}
