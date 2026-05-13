import QtQuick
import "../services"
import "../components"

/**
 * @brief Bar module displaying GPU usage as a percentage.
 *
 * The value is read from the @ref services::GpuUsage singleton (sysfs polling).
 * Clicking toggles the GPU popout via @c Visibilities.
 *
 * Tooltip: "GPU XX% - Edge YY degC" (XX = usage, YY = edge temperature).
 */
ModuleWrapper {
    id: root
    tooltip: "GPU " + GpuUsage.gpuPercent.toFixed(0) + "% · Edge " + Math.round(GpuUsage.gpuTempEdge) + " °C"

    bgIdle: Theme.moduleBg
    bgHover: Theme.accent

    StyledText {
        id: gpu
        font.pixelSize: Theme.fontSizeLg
        text: "󰢮 " + GpuUsage.gpuPercent.toFixed(0) + "%"
        color: root.hovered ? Theme.popupBg : Theme.text
    }
    onClicked: Visibilities.toggle("gpu")
}
