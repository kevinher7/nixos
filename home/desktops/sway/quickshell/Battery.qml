import QtQuick
import Quickshell.Services.UPower

Pill {
    id: root

    readonly property UPowerDevice battery: UPower.displayDevice
    readonly property bool available: battery.ready && battery.isLaptopBattery && battery.isPresent
    readonly property bool charging: available && battery.state === UPowerDeviceState.Charging
    readonly property int level: available ? Math.max(0, Math.min(10, Math.floor(battery.percentage * 10))) : 0

    icon: {
        if (!root.available)
            return "󰂑";
        if (root.charging)
            return ["󰢟", "󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"][root.level];
        if (!UPower.onBattery)
            return "󰚥";
        return ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"][root.level];
    }

    iconColor: {
        if (!root.available)
            return Theme.dark.muted;
        if (UPower.onBattery && root.battery.percentage <= 0.2)
            return Theme.dark.urgent;
        return Theme.light.accent;
    }
}
