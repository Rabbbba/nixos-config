import QtQuick
import Quickshell.Io
import Quickshell.Hyprland
import "../components"

// Hyprland layout name ("Master" / "Dwindle" / ...). Hyprland doesn't emit
// a dedicated layout-change signal, so we re-probe `hyprctl getoption` whenever
// the active toplevel changes — that's a good-enough proxy for layout shifts.
ModuleWrapper {
    id: root
    property string monitor: ""

    StyledText {
        id: lyt
        property string code: "Master"

        font.pixelSize: Theme.fontSizeLg
        font.bold: true
        text: code

        // Read the current layout via `hyprctl -j` (JSON output).
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

        // Re-probe on focus changes — proxy for layout changes.
        Connections {
            target: Hyprland
            function onActiveToplevelChanged() {
                layoutProbe.running = false;
                layoutProbe.running = true;
            }
        }
    }
}
