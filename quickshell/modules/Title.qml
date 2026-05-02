import QtQuick
import Quickshell.Hyprland

ModuleWrapper {
    id: root
    property string monitor: ""

    Text {
        color: Theme.fg1
        font.family: "Iosevka Nerd Font"
        font.pixelSize: 18
        elide: Text.ElideRight
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
