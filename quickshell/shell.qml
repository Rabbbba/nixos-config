import Quickshell
import QtQuick
import "modules"

PanelWindow {
    color: "#282828"
    implicitHeight: 30

    anchors {
        top: true
        left: true
        right: true
    }

    Tags {
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
        System {}
        Audio {}
    }
}
