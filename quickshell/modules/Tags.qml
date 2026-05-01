import QtQuick
import Quickshell.Io

Text {
    id: tags

    property string monitor: "DP-2"
    property var tagStates: Array(9).fill({
        selected: false,
        occupied: false,
        urgent: false
    })

    color: "#ebdbb2"
    font.pixelSize: 12
    text: JSON.stringify(tags.tagStates)

    Process {
        command: ["mmsg", "-w"]
        running: true

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const parts = data.split(" ");
                if (parts[0] !== tags.monitor || parts[1] !== "tag")
                    return;
                const idx = parseInt(parts[2]) - 1;
                if (idx < 0 || idx > 8)
                    return;
                const next = tags.tagStates.slice();
                next[idx] = {
                    selected: parseInt(parts[3]) === 1,
                    occupied: parseInt(parts[4]) > 0,
                    urgent: parseInt(parts[5]) === 1
                };
                tags.tagStates = next;
            }
        }
    }
}
