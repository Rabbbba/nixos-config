import QtQuick
import "../services"
import "../components"
import "../popouts"

// RAM usage % — value comes from the RamUsage singleton (polls /proc/meminfo).
ModuleWrapper {
    id: root
    tooltip: "RAM " + Math.round(RamUsage.ramPercent) + "% (" + (RamUsage.ramUsedKb / 1048576).toFixed(1) + " / " + (RamUsage.ramTotalKb / 1048576).toFixed(1) + " GiB)"

    bgIdle: Theme.moduleBg
    bgHover: Theme.accent

    StyledText {
        id: ram

        font.pixelSize: Theme.fontSizeLg
        color: root.hovered ? Theme.popupBg : Theme.text

        text: "󰍛 " + RamUsage.ramPercent.toFixed(0) + "%"
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
