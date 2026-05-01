import QtQuick
import Quickshell.Io

Row {
    id: tags

    property string monitor: "DP-2"
    property var tagStates: Array(9).fill({
        selected: false,
        occupied: false,
        urgent: false
    })

    spacing: 4

    Repeater {
        model: tags.tagStates

        Rectangle {
            id: tag
            required property var modelData
            required property int index

            width: modelData.selected ? 32 : 20
            height: 20
            radius: 4

            Text {
                anchors.centerIn: parent
                text: tag.index + 1
                color: (tag.modelData.selected || tag.modelData.occupied || tag.modelData.urgent) ? "#282828" : "#ebdbb2"
                font.pixelSize: 12
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            Behavior on width {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.InOutQuad
                }
            }

            color: {
                if (modelData.urgent)
                    return "#fb4934";
                if (modelData.selected)
                    return "#fabd2f";
                if (modelData.occupied)
                    return "#a89984";
                return "#3c3836";
            }
        }
    }

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
