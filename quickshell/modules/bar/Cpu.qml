import QtQuick
import "../../services"
import "../../components"

/**
 * @brief Bar module displaying CPU usage as a percentage.
 *
 * The value is read from the @ref services::CpuUsage singleton, which polls
 * `/proc/stat`. Clicking opens the @ref popouts::CpuPopup popout (history graph).
 *
 * Tooltip: "CPU XX% - Tctl YY degC" (XX = usage, YY = package temperature).
 */
ModuleWrapper {
    id: root

    bgIdle: Theme.moduleBg
    bgHover: Theme.accent

    tooltip: "CPU " + Math.round(CpuUsage.cpuPercent) + "% · Tctl " + Math.round(CpuUsage.cpuTemp) + " °C"

    // Worst-case slot width (icon + "100%") — keeps the module width stable.
    TextMetrics {
        id: cpuMetrics
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeLg
        text: cpu.text.replace(/[0-9]+%/, "100%")
    }

    StyledText {
        id: cpu
        font.pixelSize: Theme.fontSizeLg
        width: cpuMetrics.width
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideNone
        text:"󰘚 " + CpuUsage.cpuPercent.toFixed(0) + "%"
        color: root.hovered ? Theme.popupBg : Theme.text
    }

    onClicked: Visibilities.toggle("cpu")
}
