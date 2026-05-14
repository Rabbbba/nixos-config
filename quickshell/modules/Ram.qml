import QtQuick
import "../services"
import "../components"

/**
 * @brief Bar module displaying RAM usage as a percentage.
 *
 * The value is read from the @ref services::RamUsage singleton (polls `/proc/meminfo`).
 * Clicking toggles the RAM popout via @c Visibilities.
 *
 * Tooltip: "RAM XX% (used / total GiB)".
 */
ModuleWrapper {
    id: root
    tooltip: "RAM " + Math.round(RamUsage.ramPercent) + "% (" + (RamUsage.ramUsedKb / 1048576).toFixed(1) + " / " + (RamUsage.ramTotalKb / 1048576).toFixed(1) + " GiB)"

    bgIdle: Theme.moduleBg
    bgHover: Theme.accent

    // Worst-case slot width (icon + "100%") — keeps the module width stable.
    TextMetrics {
        id: ramMetrics
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeLg
        text: ram.text.replace(/[0-9]+%/, "100%")
    }

    StyledText {
        id: ram

        font.pixelSize: Theme.fontSizeLg
        color: root.hovered ? Theme.popupBg : Theme.text
        width: ramMetrics.width
        horizontalAlignment: Text.AlignLeft
        elide: Text.ElideNone

        text:"󰍛 " + RamUsage.ramPercent.toFixed(0) + "%"
    }

    onClicked: Visibilities.toggle("ram")
}
