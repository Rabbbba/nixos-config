import Quickshell
import QtQuick
import "modules"

Variants {
    model: Quickshell.screens
    PanelWindow {
        color: "#282828"
        implicitHeight: 30
        required property var modelData
        anchors {
            top: true
            left: true
            right: true
        }
        screen: modelData

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
            Audio {}
        }
    }
}
