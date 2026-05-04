import QtQuick
import "../services"
import "../components"
import "../popouts"

ModuleWrapper {
    id: root

    tooltip: "Gpu usage"

    StyledText {
        id: gpu
        font.pixelSize: Theme.fontSizeLg
        text: "󰢮 " + GpuUsage.gpuPercent.toFixed(0) + "%"
    }

    ModulePopout {
        wrapper: root
        name: "gpu"
        implicitWidth: 360
        implicitHeight: 200
        alignment: "center"

        CpuPopup {
            anchors.fill: parent
        }
    }

    onClicked: Visibilities.toggle("gpu")
}
