import QtQuick
import "../services"

/**
 * @brief Horizontal progress bar — value is clamped to [0, 1].
 *
 * Examples:
 * @code
 * ProgressBar { value: 0.42 }
 * ProgressBar { value: 0.8; fillColor: Theme.color.alert }
 * @endcode
 */
Rectangle {
    id: root

    /** Progress value in [0, 1]. Out-of-range values are clamped. */
    property real value: 0
    /** Fill color of the progress bar. Defaults to the theme accent. */
    property color fillColor: Theme.color.accent

    implicitHeight: 8
    radius: height / 2
    color: Theme.color.moduleBg

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * Math.max(0, Math.min(1, root.value))
        radius: parent.radius
        color: root.fillColor
    }
}
