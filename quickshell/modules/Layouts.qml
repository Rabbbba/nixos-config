import QtQuick
import Quickshell.Io

ModuleWrapper {
    id: root
    property string monitor: ""

    Text {
        id: lyt
        property string code: ""
        property var labels: ({
                "T": "Tile",
                "M": "Monocle",
                "VS": "VStack",
                "HS": "HStack",
                "F": "Float"
            })

        color: Theme.fg1
        font.family: "Iosevka Nerd Font"
        font.pixelSize: 18
        font.bold: true
        text: labels[code] || code

        Process {
            command: ["mmsg", "-w"]
            running: true
            stdout: SplitParser {
                splitMarker: "\n"
                onRead: data => {
                    const parts = data.split(" ");
                    if (parts[0] !== root.monitor)
                        return;
                    if (parts[1] !== "layout")
                        return;
                    lyt.code = parts[2];
                }
            }
        }
    }
}
