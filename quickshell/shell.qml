import Quickshell
import QtQuick
import "modules"
import "services"
import "components"

Scope {
    Variants {
        model: Quickshell.screens.filter(s => s.name === "DP-2")
        PanelWindow {
            id: panel
            color: "transparent"
            implicitHeight: 40
            required property var modelData
            anchors {
                top: true
                left: true
                right: true
            }

            screen: modelData

            Rectangle {
                anchors.fill: parent
                color: Theme.bg0
                Row {
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 10
                    Tags {
                        monitor: modelData.name
                    }
                    Title {
                        monitor: modelData.name
                    }
                    Layouts {
                        monitor: modelData.name
                    }
                }

                Clock {
                    panelWindow: panel
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 8
                    }
                    spacing: 12
                    Tidal {
                        panelWindow: panel
                    }
                    Ram {}
                    Cpu {}
                    Network {}
                    Audio {}
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens.filter(s => s.name === "DP-2")
        PanelWindow {
            id: rightPanel
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            implicitWidth: hover.containsMouse ? 48 : 14
            required property var modelData
            screen: modelData
            anchors {
                right: true
                top: true
                bottom: true
            }

            Behavior on implicitWidth {
                NumberAnimation {
                    duration: Theme.animSlow
                    easing.type: Easing.OutCubic
                }
            }

            MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
            }

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.bg0
                radius: 18
                width: parent.width
                height: 220
                border.color: Theme.bg3
                border.width: 1
                clip: true

                Column {
                    anchors.centerIn: parent
                    spacing: 12
                    opacity: hover.containsMouse ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.animFast
                        }
                    }

                    Power {}
                }
            }
        }
    }
}
