import QtQuick
import Quickshell
import Quickshell.Hyprland

Row {
    id: tags

    property string monitor: ""

    spacing: 4

    Repeater {
        // Workspaces filtrés par moniteur, triés par id
        model: ScriptModel {
            values: Hyprland.workspaces.values
                .filter(ws => ws.monitor && ws.monitor.name === tags.monitor)
                .sort((a, b) => a.id - b.id)
        }

        Rectangle {
            id: tag
            required property var modelData

            // Sur Hyprland un seul workspace par moniteur est actif à la fois
            property bool active: modelData.active
            property bool occupied: modelData.toplevels && modelData.toplevels.values.length > 0
            property bool urgent: modelData.urgent

            width: active ? 32 : 20
            height: 30
            radius: 4

            Text {
                anchors.centerIn: parent
                text: tag.modelData.id
                color: (tag.active || tag.occupied || tag.urgent) ? Theme.bg0 : Theme.fg1
                font.pixelSize: 18
            }

            MouseArea {
                id: ma
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + tag.modelData.id)
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
                if (tag.urgent)
                    return Theme.red;
                if (tag.active)
                    return Theme.yellow;
                if (tag.occupied)
                    return Theme.fg4;
                if (ma.containsMouse)
                    return Theme.bg2;
                return Theme.bg1;
            }
        }
    }
}
