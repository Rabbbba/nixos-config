import QtQuick
import "../services"
import "../components"

// RAM usage % — value comes from the SystemUsage singleton (polls /proc/meminfo).
ModuleWrapper {
    id: root

    StyledText {
        id: ram

        font.pixelSize: Theme.fontSizeLg
        text: "󰍛 " + SystemUsage.ramPercent.toFixed(0) + "%"
    }
}
