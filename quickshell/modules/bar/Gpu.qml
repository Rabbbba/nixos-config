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

    bgIdle: Theme.moduleBg
    bgHover: Theme.accent

    // Worst-case slot width (icon + "100%") — keeps the module width stable.
    TextMetrics {
        id: gpuMetrics
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeLg
        text: gpu.text.replace(/[0-9]+%/, "100%")
    }

    StyledText {
        id: gpu
        font.pixelSize: Theme.fontSizeLg
        width: gpuMetrics.width
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideNone
        text:"󰢮 " + GpuUsage.gpuPercent.toFixed(0) + "%"
        color: root.hovered ? Theme.popupBg : Theme.text
    }
    onClicked: Visibilities.toggle("gpu")
}
