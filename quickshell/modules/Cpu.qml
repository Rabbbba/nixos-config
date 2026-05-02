import QtQuick
import "../services"
import "../components"

ModuleWrapper {
    id: root

    StyledText {
        id: cpu

        font.pixelSize: Theme.fontSizeLg
        text: "󰘚 " + SystemUsage.cpuPercent.toFixed(0) + "%"
    }
}
