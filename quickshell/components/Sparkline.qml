pragma ComponentBehavior: Bound
// qmllint disable missing-property
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
    property color color: Theme.color.accent
    /** Horizontal spacing between bars in pixels. */
    property int barSpacing: 2
    /** Values at or below this threshold are rendered as empty. */
    property real noiseFloor: 0
    /** Minimum height for visible non-zero bars. */
    property real minBarHeight: 2

    implicitHeight: 28

    /**
     * Compute the rendered bar height for one sample.
     * @param value Numeric sample value.
     */
    function barHeight(value: real): real {
        if (!Number.isFinite(value) || value <= root.noiseFloor || root.maxValue <= 0)
            return 0;

        return Math.max(root.minBarHeight, (value / root.maxValue) * root.height);
    }

    Repeater {
        model: root.values
        Rectangle {
            required property int index

            width: (root.width - (root.values.length - 1) * root.barSpacing) / root.values.length
            x: index * (width + root.barSpacing)
            anchors.bottom: parent.bottom
            height: root.barHeight(root.values[index])
            color: root.color
            radius: 1
        }
    }
}
