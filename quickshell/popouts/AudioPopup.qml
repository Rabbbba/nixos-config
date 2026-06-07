// qmllint disable missing-property
import QtQuick
import Quickshell.Services.Pipewire
import "../services"
import "../components"

/**
 * @brief Audio output selector — lists physical sinks with per-row volume slider.
 *
 * Click a row's name to make that sink the default Pipewire audio sink. The
 * track at the bottom of each row doubles as a per-sink volume slider (drag
 * to set). Only physical sinks are shown (no app streams).
 */
Item {
    id: root
    anchors.fill: parent

    /**
     * Filtered list of physical audio sinks (no app streams, must expose
     * an audio object). Updated reactively as Pipewire nodes come and go.
     */
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio !== null)

    // Pipewire bindings are lazy — track every sink we display so live state (volume, muted) stays current.
    PwObjectTracker {
        objects: root.sinks
    }

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        SectionHeader {
            text: "Audio output"
        }

        Repeater {
            model: root.sinks

            delegate: Item {
                id: row
                required property PwNode modelData
                required property int index

                width: parent.width
                height: 48

                readonly property bool isDefault: Pipewire.defaultAudioSink === row.modelData

                HoverHandler {
                    id: rowHover
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -4
                    radius: 6
                    color: Theme.color.moduleBg
                    opacity: rowHover.hovered ? 0.6 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }

                MouseArea {
                    id: clickArea
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: 24
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Pipewire.defaultAudioSink = row.modelData
                }

                StyledText {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    text: (row.isDefault ? "● " : "○ ") + (row.modelData.description || row.modelData.nickname || row.modelData.name)
                    color: row.isDefault ? Theme.color.accent : Theme.color.text
                }

                Rectangle {
                    id: track
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 6
                    radius: 3
                    color: Theme.color.moduleBg

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width * (row.modelData.audio ? row.modelData.audio.volume : 0)
                        radius: 3
                        color: row.isDefault ? Theme.color.accent : Theme.color.textMuted
                    }

                    MouseArea {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        height: 16
                        cursorShape: Qt.PointingHandCursor

                        function setFromX(x) {
                            const ratio = Math.max(0, Math.min(1, x / track.width));
                            if (row.modelData.audio)
                                row.modelData.audio.volume = ratio;
                        }

                        onPressed: mouse => setFromX(mouse.x)
                        onPositionChanged: mouse => {
                            if (pressed)
                                setFromX(mouse.x);
                        }
                    }
                }
            }
        }
    }
}
