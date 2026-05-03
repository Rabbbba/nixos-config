import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../components"

// Hyprland workspace ("tag") indicators. One pill per workspace on this
// monitor, click to switch, scroll to step through workspaces.
// Active pill is wider + colored; occupied / urgent / hover have their own colors.
Row {
    id: tags

    property string monitor: ""

    spacing: 4

    Repeater {
        // Workspaces filtered to this monitor, sorted by id.
        model: ScriptModel {
            values: Hyprland.workspaces.values.filter(ws => ws.monitor && ws.monitor.name === tags.monitor).sort((a, b) => a.id - b.id)
        }

        Rectangle {
            id: tag
            required property var modelData

            // On Hyprland only one workspace per monitor is active at any time.
            property bool active: modelData.active
            property bool occupied: modelData.toplevels && modelData.toplevels.values.length > 0
            property bool urgent: modelData.urgent

            width: active ? 32 : 20
            height: 30
            radius: 4

            StyledText {
                anchors.centerIn: parent
                text: tag.modelData.id
                color: (tag.active || tag.occupied || tag.urgent) ? Theme.bg0 : Theme.fg1
                font.pixelSize: Theme.fontSizeMd
            }

            MouseArea {
                id: ma
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + tag.modelData.id)

                onWheel: wheel => {
                    if (wheel.angleDelta.y > 0)
                        Hyprland.dispatch("workspace m-1");
                    else
                        Hyprland.dispatch("workspace m+1");
                }
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
