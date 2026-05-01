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

        Tags {
            monitor: modelData.name
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: 8
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
