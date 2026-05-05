import QtQuick
import "../services"
import "../modules"
import "../components"

Item {
    id: root
    anchors.fill: parent

    // Format bytes → "X.XX GiB" (binary gibibyte, 1024³ = 1073741824).
    function fmtGi(bytes) {
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
                color: Theme.accent
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
                value: GpuUsage.vramUsed / GpuUsage.vramTotal
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
