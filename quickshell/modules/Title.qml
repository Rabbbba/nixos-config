import QtQuick
import Quickshell.Hyprland
import "../components"

// Active window title — only renders if the focused toplevel lives on
// this module's monitor (so the bar doesn't echo the other monitor's title).
// Width is capped at 400 px and ellipsized via StyledText.
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
