import Quickshell
import QtQuick
import "modules"

Variants {
    model: Quickshell.screens
    PanelWindow {
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
                Ram {}
                Cpu {}
                Network {}
                Audio {}
            }
        }
    }
}
