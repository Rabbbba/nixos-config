import QtQuick
import "../services"
import "../components"

ModuleWrapper {
    id: root

    StyledText {
        id: ram

        font.pixelSize: Theme.fontSizeLg
        text: "󰍛 " + SystemUsage.ramPercent.toFixed(0) + "%"
    }
}
