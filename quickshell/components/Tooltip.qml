import QtQuick
import Quickshell
import "../modules"

/**
 * @brief Small tooltip popup anchored below a parent item.
 *
 * Used by @ref modules::ModuleWrapper and @ref modules::SystemTray on hover.
 * Anchor is recomputed on every visibility change so the tooltip stays
 * centered horizontally on @ref parentItem and 4 px below it.
 */
PopupWindow {
    id: tooltip

    /** Item the tooltip is anchored to (tooltip is centered horizontally on it). */
    required property Item parentItem
    /** PanelWindow used as the anchor reference for coordinate mapping. */
    required property var panelWindow
    /** Tooltip text. Empty string makes the tooltip invisible. */
    property string text: ""

    color: "transparent"
    implicitWidth: label.implicitWidth + 16
    implicitHeight: label.implicitHeight + 8

    anchor.window: panelWindow
    visible: false

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: Theme.moduleBg
        border.width: 1
        border.color: Theme.border

        opacity: tooltip.visible ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animFast
                easing.type: Easing.OutCubic
            }
        }

        StyledText {
            id: label
            anchors.centerIn: parent
            text: tooltip.text
            color: Theme.text
            font.pixelSize: Theme.fontSizeSm
        }
    }

    onVisibleChanged: {
        if (!visible)
            return;

        anchor.rect.x = parentItem.mapToItem(panelWindow.contentItem, parentItem.width / 2 - implicitWidth / 2, 0).x;
        anchor.rect.y = parentItem.mapToItem(panelWindow.contentItem, 0, parentItem.height + 4).y;
    }
}
