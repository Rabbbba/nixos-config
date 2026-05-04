import QtQuick
import "../modules"

// Horizontal progress bar. value is clamped to [0, 1].
//     ProgressBar { value: 0.42 }
//     ProgressBar { value: 0.8; fillColor: Theme.alert }
Rectangle {
    id: root
    property real value: 0
    property color fillColor: Theme.accent

    implicitHeight: 8
    radius: height / 2
    color: Theme.moduleBg

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * Math.max(0, Math.min(1, root.value))
        radius: parent.radius
        color: root.fillColor
    }
}
