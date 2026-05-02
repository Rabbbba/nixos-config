import QtQuick
import Quickshell.Io
import Quickshell.Hyprland

ModuleWrapper {
    id: root
    property string monitor: ""

    Text {
        id: lyt
        property string code: "Master"

        color: Theme.fg1
        font.family: "Iosevka Nerd Font"
        font.pixelSize: 18
        font.bold: true
        text: code

        // Récupère le layout courant via hyprctl à chaque changement de focus
        Process {
            id: layoutProbe
            command: ["hyprctl", "getoption", "general:layout", "-j"]
            running: true
            stdout: SplitParser {
                splitMarker: ""
                onRead: data => {
                    try {
                        const obj = JSON.parse(data);
                        const v = (obj.str || "").trim();
                        if (v === "master")
                            lyt.code = "Master";
                        else if (v === "dwindle")
                            lyt.code = "Dwindle";
                        else if (v)
                            lyt.code = v;
                    } catch (e) {}
                }
            }
        }

        // Re-probe quand le toplevel actif change (sniff de changements de layout)
        Connections {
            target: Hyprland
            function onActiveToplevelChanged() {
                layoutProbe.running = false;
                layoutProbe.running = true;
            }
        }
    }
}
