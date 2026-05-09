import QtQuick
import "../services"
import "../components"
import "../popouts"

/**
 * @brief Bar module displaying RAM usage as a percentage.
 *
 * The value is read from the @ref services::RamUsage singleton (polls `/proc/meminfo`).
 * Clicking opens the @ref popouts::RamPopup popout (history + buffers + swap).
 *
 * Tooltip: "RAM XX% (used / total GiB)".
 */
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
