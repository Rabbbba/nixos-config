import QtQuick
import Quickshell

/**
 * @brief Invisible 1×1 panel that reserves an exclusive zone on one screen edge.
 *
 * Click-through (empty mask) — used to carve out space in the layer-shell
 * layout for the decorative border, without intercepting any input.
 */
PanelWindow {
    id: root

    /** Screen this zone is anchored to (a `Quickshell.screens` entry). */
    required property var modelData
    /** Edge to anchor on: one of `"top"`, `"bottom"`, `"left"`, `"right"`. */
    required property string anchorSide
    /** Size of the reserved exclusive zone in pixels. */
    required property int exclusiveZoneSize

    color: "transparent"
    mask: Region {}
    implicitWidth: 1
    implicitHeight: 1
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: root.exclusiveZoneSize
    screen: root.modelData

    anchors {
        top: anchorSide === "top" || anchorSide === "left" || anchorSide === "right"
        bottom: anchorSide === "bottom" || anchorSide === "left" || anchorSide === "right"
        left: anchorSide === "left" || anchorSide === "top" || anchorSide === "bottom"
        right: anchorSide === "right" || anchorSide === "top" || anchorSide === "bottom"
    }
}
