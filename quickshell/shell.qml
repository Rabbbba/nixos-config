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
            implicitWidth: 45
            required property var modelData
            screen: modelData
            anchors {
                top: true
                right: true
                bottom: true
            }

            Rectangle {
                anchors.fill: parent
                color: Theme.bg0

                Column {
                    anchors.centerIn: parent
                    spacing: 12

                    Power {}
                }
            }
        }
    }
}
