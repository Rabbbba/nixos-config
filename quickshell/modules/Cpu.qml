import QtQuick
import "../services"
import "../components"
import "../popouts"

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

    StyledText {
        id: cpu
        font.pixelSize: Theme.fontSizeLg
        text: "󰘚 " + CpuUsage.cpuPercent.toFixed(0) + "%"
        color: root.hovered ? Theme.popupBg : Theme.text
    }

    ModulePopout {
        wrapper: root
        name: "cpu"
        implicitWidth: 360
        implicitHeight: 230
        alignment: "center"

        CpuPopup {
            anchors.fill: parent
        }
    }

    onClicked: Visibilities.toggle("cpu")
}
