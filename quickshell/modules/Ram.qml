import QtQuick
import "../services"
ModuleWrapper {
    id: root

    Text {
        id: ram

        color: Theme.fg1
        font.pixelSize: 20
        font.family: "Iosevka Nerd Font"
        text: "󰍛 " + SystemUsage.ramPercent.toFixed(0) + "%"

    }
}
