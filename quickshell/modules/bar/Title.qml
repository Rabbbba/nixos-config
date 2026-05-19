import QtQuick
import Quickshell.Hyprland
import "../../components"
import "../../services"

/**
 * @brief Active window title — only renders for toplevels on this module's monitor.
 *
 * Avoids echoing the other monitor's title. Width is capped at 400 px and
 * ellipsized via @ref components::StyledText.
 */
ModuleWrapper {
    id: root

    /** Name of the monitor whose active toplevel title is displayed. */
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
