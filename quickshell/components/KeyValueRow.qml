import QtQuick
import "../modules"

// One-line row with a label on the left and a value on the right.
//     KeyValueRow { label: "Memory"; value: "4.2 / 16 GiB" }
Item {
    id: root
    property alias label: leftLabel.text
    property alias value: rightLabel.text
    property color valueColor: Theme.textMuted

    implicitHeight: 18

    StyledText {
        id: leftLabel
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
    }

    StyledText {
        id: rightLabel
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        color: root.valueColor
    }
}
