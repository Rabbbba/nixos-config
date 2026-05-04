import QtQuick
import "../services"

// Popout attached to a bar module. Wires parentItem, panelWindow, and the
// Visibilities-driven open/close so the call site only declares alignement,
// sizing, and content.
//
// Usage:
//     ModulePopout {
//         wrapper: root
//         name: "audio"
//         alignement: "right"
//         implicitWidth: 300
//         implicitHeight: 200
//         AudioPopup { anchors.fill: parent }
//     }
Popout {
    id: root
    required property var wrapper
    required property string name

    parentItem: wrapper
    panelWindow: wrapper.panelWindow
    visible: Visibilities.current === name
}
