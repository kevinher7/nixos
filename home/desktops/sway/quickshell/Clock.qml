import Quickshell
import QtQuick

Pill {
    icon: ""
    label: Qt.formatDateTime(clock.date, "HH:mm")

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }
}
