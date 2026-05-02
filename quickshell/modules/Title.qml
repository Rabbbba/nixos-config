import QtQuick
import Quickshell.Hyprland
import "../components"

ModuleWrapper {
    id: root
    property string monitor: ""

    StyledText {
        font.pixelSize: Theme.fontSizeMd
        width: Math.min(implicitWidth, 400)
        horizontalAlignment: Text.AlignLeft

        text: {
            const top = Hyprland.activeToplevel;
            if (!top || !top.monitor)
                return "";
            if (top.monitor.name !== root.monitor)
                return "";
            return top.title || "";
        }
    }
}
