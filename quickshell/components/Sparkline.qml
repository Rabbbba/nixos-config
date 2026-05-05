pragma ComponentBehavior: Bound
import QtQuick
import "../modules"

Item {
    id: root

    property var values: []
    property real maxValue: 100
    property color color: Theme.accent
    property int barSpacing: 2

    implicitHeight: 28

    Repeater {
        model: root.values
        Rectangle {
            required property int index

            width: (root.width - (root.values.length - 1) * root.barSpacing) / root.values.length
            x: index * (width + root.barSpacing)
            anchors.bottom: parent.bottom
            height: Math.max(2, (root.values[index] / root.maxValue) * root.height)
            color: root.color
            radius: 1
        }
    }
}
