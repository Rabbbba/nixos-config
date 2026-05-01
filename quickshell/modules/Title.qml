import QtQuick
import Quickshell.Io

ModuleWrapper {
    id: root
    property string monitor: ""    // passé depuis shell.qml comme pour Tags

    Text {
        id: title
        property string current: ""    // le titre courant

        color: Theme.fg1
        font.family: "Iosevka Nerd Font"
        font.pixelSize: 18              // un peu plus petit que les modules
        text: current
        elide: Text.ElideRight          // tronque avec "..." si trop long
        width: Math.min(implicitWidth, 400)
        horizontalAlignment: Text.AlignLeft

        Process {
            command: ["mmsg", "-w"]
            running: true

            stdout: SplitParser {
                splitMarker: "\n"
                onRead: data => {
                    const parts = data.split(" ");
                    if (parts[0] !== root.monitor)
                        return;
                    if (parts[1] !== "title")
                        return;
                    title.current = parts.slice(2).join(" ");
                }
            }
        }
    }
}
