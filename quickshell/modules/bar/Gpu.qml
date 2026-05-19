import QtQuick
import "../../services"
import "../../components"

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

    bgIdle: Theme.color.moduleBg
    bgHover: Theme.color.accent

    // Worst-case slot width (icon + "100%") — keeps the module width stable.
    TextMetrics {
        id: gpuMetrics
        font.family: Theme.font.family
        font.pixelSize: Theme.font.sizeLg
        text: gpu.text.replace(/[0-9]+%/, "100%")
    }

    StyledText {
        id: gpu
        font.pixelSize: Theme.font.sizeLg
        width: gpuMetrics.width
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideNone
        text:"󰢮 " + GpuUsage.gpuPercent.toFixed(0) + "%"
        color: root.hovered ? Theme.color.popupBg : Theme.color.text
    }
    onClicked: Visibilities.toggle("gpu")
}
