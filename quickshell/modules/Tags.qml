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
            height: 30
            radius: 4

            Text {
                anchors.centerIn: parent
                text: tag.index + 1
                color: (tag.modelData.selected || tag.modelData.occupied || tag.modelData.urgent) ? Theme.bg0 : Theme.fg1
                font.pixelSize: 18
            }

            MouseArea {
                id: ma
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor       // curseur "main" pour signaler clickable
                onClicked: switcher.command = ["mmsg", "-s", "-d", "view," + (tag.index + 1)]
            }

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animFast
                }
            }

            Behavior on width {
                NumberAnimation {
                    duration: Theme.animFast
                    easing.type: Easing.InOutQuad
                }
            }

            color: {
                if (modelData.urgent)
                    return Theme.red;
                if (modelData.selected)
                    return Theme.yellow;
                if (modelData.occupied)
                    return Theme.fg4;
                if (ma.containsMouse)
                    return Theme.bg2;
                return Theme.bg1;
            }
        }
    }

    Process {
        id: switcher
        running: false
        onCommandChanged: if (command.length > 0)
            running = true
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
