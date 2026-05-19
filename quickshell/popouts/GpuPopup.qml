import QtQuick
import "../services"
import "../components"

/**
 * @brief GPU popup body — usage + sparkline, VRAM, and temperatures.
 *
 * Reads from the @ref services::GpuUsage singleton. Meant to be placed inside
 * a @ref components::PopoutItem (sized by the call site).
 */
Item {
    id: root
    anchors.fill: parent

    /**
     * Format a byte count as a `"X.XX GiB"` string (binary gibibyte, 1024³ bytes).
     * @param bytes Byte count.
     */
    function fmtGi(bytes: real): string {
        return (bytes / 1073741824).toFixed(2) + " GiB";
    }

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        Column {
            width: parent.width
            spacing: 6

            SectionHeader {
                text: "Gpu"
            }

            KeyValueRow {
                width: parent.width
                label: "Usage"
                value: Math.round(GpuUsage.gpuPercent) + "%"
            }

            ProgressBar {
                width: parent.width
                value: GpuUsage.gpuPercent / 100
            }

            Sparkline {
                width: parent.width
                values: GpuUsage.gpuHistory
                color: Theme.color.accent
            }
        }

        Column {
            width: parent.width
            spacing: 6

            SectionHeader {
                text: "VRAM"
            }
            KeyValueRow {
                width: parent.width
                label: root.fmtGi(GpuUsage.vramUsed) + " / " + root.fmtGi(GpuUsage.vramTotal)
                value: "(" + Math.round(GpuUsage.vramPercent) + "%)"
            }

            ProgressBar {
                width: parent.width
                value: GpuUsage.vramTotal > 0 ? GpuUsage.vramUsed / GpuUsage.vramTotal : 0
            }
        }

        Column {
            width: parent.width
            spacing: 6

            SectionHeader {
                text: "Thermal"
            }

            KeyValueRow {
                width: parent.width
                label: "Edge"
                value: Math.round(GpuUsage.gpuTempEdge) + " °C"
            }
            KeyValueRow {
                width: parent.width
                label: "Junction"
                value: Math.round(GpuUsage.gpuTempJunction) + " °C"
            }
            KeyValueRow {
                width: parent.width
                label: "Memory"
                value: Math.round(GpuUsage.gpuTempMem) + " °C"
            }
        }
    }
}
