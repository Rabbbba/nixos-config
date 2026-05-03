import QtQuick
import "../services"
import "../components"

// CPU usage % — value comes from the SystemUsage singleton (polls /proc/stat).
ModuleWrapper {
    id: root

    StyledText {
        id: cpu

        font.pixelSize: Theme.fontSizeLg
        text: "󰘚 " + SystemUsage.cpuPercent.toFixed(0) + "%"
    }
}
