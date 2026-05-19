pragma ComponentBehavior: Bound
import QtQuick
import "../services"

/**
 * @brief Bar-chart sparkline — one bar per value, normalized to @ref maxValue.
 *
 * Used by Cpu/Ram/Gpu popups to show rolling history (one entry per poll tick).
 * Bars are drawn from the bottom up, anchored to the bottom of the item.
 */
Item {
    id: root

    /** Array of numeric values to display (one bar per entry). */
    property var values: []
    /** Maximum reference value used for normalization. */
    property real maxValue: 100
    /** Color applied to each bar. Defaults to the theme accent. */
    property color color: Theme.accent
    /** Horizontal spacing between bars in pixels. */
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
