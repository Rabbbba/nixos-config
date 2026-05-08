import QtQuick
import Quickshell

PanelWindow {
    id: root

    required property var modelData
    required property string anchorSide
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
