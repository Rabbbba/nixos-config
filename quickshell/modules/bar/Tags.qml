// qmllint disable missing-property
import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../components"
import "../../services"

/**
 * @brief Hyprland workspace ("tag") indicators — one pill per workspace on this monitor.
 *
 * Click to switch workspace, scroll to step through workspaces. The active
 * pill is wider and colored with the theme accent; occupied / urgent / hover
 * states each have their own color in the theme palette.
 */
Row {
    id: tags

    /** Name of the monitor whose workspaces are displayed. */
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
                color: (tag.active || tag.occupied || tag.urgent) ? Theme.color.windowBg : Theme.color.text
                font.pixelSize: Theme.font.sizeMd
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
                    duration: Theme.anim.fast
                }
            }

            Behavior on width {
                NumberAnimation {
                    duration: Theme.anim.fast
                    easing.type: Easing.InOutQuad
                }
            }

            color: {
                if (tag.urgent)
                    return Theme.color.alert;
                if (tag.active)
                    return Theme.color.accent;
                if (tag.occupied)
                    return Theme.color.textMuted;
                if (ma.containsMouse)
                    return Theme.color.moduleBg;
                return Theme.color.popupBg;
            }
        }
    }
}
