import QtQuick
import "../services"
import "../components"
import "../popouts"

// RAM usage % — value comes from the SystemUsage singleton (polls /proc/meminfo).
ModuleWrapper {
    id: root

    tooltip: "Ram usage"
    StyledText {
        id: ram

        font.pixelSize: Theme.fontSizeLg
        text: "󰍛 " + SystemUsage.ramPercent.toFixed(0) + "%"
    }

    ModulePopout {
        wrapper: root
        name: "ram"
        alignment: "center"
        implicitWidth: 320
        implicitHeight: 230

        RamPopup {
            anchors.fill: parent
        }
    }

    onClicked: Visibilities.toggle("ram")
}
