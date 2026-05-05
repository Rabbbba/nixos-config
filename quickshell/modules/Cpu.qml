import QtQuick
import "../services"
import "../components"
import "../popouts"

// CPU usage % — value comes from the CpuUsage singleton (polls /proc/stat).
ModuleWrapper {
    id: root

    tooltip: "CPU " + Math.round(CpuUsage.cpuPercent) + "% · Tctl " + Math.round(CpuUsage.cpuTemp) + " °C"

    StyledText {
        id: cpu
        font.pixelSize: Theme.fontSizeLg
        text: "󰘚 " + CpuUsage.cpuPercent.toFixed(0) + "%"
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
