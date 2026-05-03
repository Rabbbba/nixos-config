import QtQuick
import "../services"
import "../components"
import "../popouts"

// CPU usage % — value comes from the SystemUsage singleton (polls /proc/stat).
ModuleWrapper {
    id: root

    tooltip: "Cpu usage"

    StyledText {
        id: cpu

        font.pixelSize: Theme.fontSizeLg
        text: "󰘚 " + SystemUsage.cpuPercent.toFixed(0) + "%"
    }

    Popout {
        parentItem: root
        panelWindow: root.panelWindow
        implicitWidth: 360
        implicitHeight: 200
        alignement: "center"
        visible: Visibilities.current === "cpu"

        CpuPopup {
            anchors.fill: parent
        }
    }

    onClicked: Visibilities.toggle("cpu")
}
