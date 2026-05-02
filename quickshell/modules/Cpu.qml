import QtQuick
import "../services"

ModuleWrapper {
    id: root

    Text {
        id: cpu

        color: Theme.fg1
        font.pixelSize: 20
        font.family: "Iosevka Nerd Font"
        text: "󰘚 " + SystemUsage.cpuPercent.toFixed(0) + "%"

    }
}
