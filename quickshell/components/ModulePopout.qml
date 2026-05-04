import QtQuick
import Quickshell.Hyprland
import "../services"

// Popout attached to a bar module. Wires parentItem, panelWindow, and the
// Visibilities-driven open/close so the call site only declares alignment,
// sizing, and content.
//
// Usage:
//     ModulePopout {
//         wrapper: root
//         name: "audio"
//         alignment: "right"
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

    // Click outside both the popup and the bar → close. The bar is included
    // so clicking another module still toggles popups instead of being eaten
    // by the grab.
    HyprlandFocusGrab {
        active: root.visible
        windows: [root, root.panelWindow]
        onCleared: Visibilities.close()
    }
}
