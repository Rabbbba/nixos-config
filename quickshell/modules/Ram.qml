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

    Popout {
        parentItem: root
        panelWindow: root.panelWindow
        implicitHeight: 200
        implicitWidth: 320
        alignement: "center"
        visible: Visibilities.current === "ram"

        RamPopup {
            anchors.fill: parent
        }
    }
    onClicked: Visibilities.toggle("ram")
}
