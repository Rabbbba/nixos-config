// qmllint disable missing-property
import QtQuick
import "../services"

/**
 * @brief One-line row with a label on the left and a value on the right.
 *
 * Example:
 * @code
 * KeyValueRow { label: "Memory"; value: "4.2 / 16 GiB" }
 * @endcode
 */
Item {
    id: root

    /** Left-side text (typically the metric name). */
    property alias label: leftLabel.text
    /** Right-side text (typically the metric value). */
    property alias value: rightLabel.text
    /** Color applied to the right-side value. Defaults to muted. */
    property color valueColor: Theme.color.textMuted

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
