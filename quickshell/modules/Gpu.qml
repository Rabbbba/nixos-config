import QtQuick
import "../services"
import "../components"
import "../popouts"

ModuleWrapper {
    id: root
    tooltip: "GPU " + GpuUsage.gpuPercent.toFixed(0) + "% · Edge " + Math.round(GpuUsage.gpuTempEdge) + " °C"

    StyledText {
        id: gpu
        font.pixelSize: Theme.fontSizeLg
        text: "󰢮 " + GpuUsage.gpuPercent.toFixed(0) + "%"
    }

    ModulePopout {
        wrapper: root
        name: "gpu"
        implicitWidth: 360
        implicitHeight: 320
        alignment: "center"

        GpuPopup {
            anchors.fill: parent
        }
    }

    onClicked: Visibilities.toggle("gpu")
}
