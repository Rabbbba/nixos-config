import QtQuick
import "../services"
import "../components"
import "../popouts"

// CPU usage % — value comes from the SystemUsage singleton (polls /proc/stat).
ModuleWrapper {
    id: root

    tooltip: "CPU " + Math.round(SystemUsage.cpuPercent) + "% · Tctl " + Math.round(SystemUsage.cpuTemp) + " °C"

    StyledText {
        id: cpu
        font.pixelSize: Theme.fontSizeLg
        text: "󰘚 " + SystemUsage.cpuPercent.toFixed(0) + "%"
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
