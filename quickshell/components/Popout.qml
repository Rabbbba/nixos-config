import QtQuick
import Quickshell
import "../modules"

/**
 * @brief Generic popout window anchored under a bar item.
 *
 * Consumers write `Popout { parentItem: someItem; panelWindow: bar; ... <content> }`
 * and the content lands inside @c container (padded), not as a direct child of
 * the @c PopupWindow. Pop-in animation: opacity 0→1 + scale 0.96→1 on visible
 * toggle. Anchor is recomputed on every visibility change based on @ref alignment.
 */
PopupWindow {
    id: popout

    /** Item the popout is anchored under (popout sits below it). */
    required property Item parentItem
    /** PanelWindow used as the anchor reference for coordinate mapping. */
    required property var panelWindow

    /** Inner padding in pixels between the panel border and the content slot. */
    property int padding: 14

    /**
     * Horizontal alignment of the popout relative to @ref parentItem.
     * Valid values:
     * - `"left"`   → popout's left edge aligns with parent's left
     * - `"center"` → popout horizontally centered on the parent
     * - `"right"`  → popout's right edge aligns with parent's right
     */
    property string alignment: "center"

    // Default property: anything declared inside a Popout {} block is reparented
    // into `container.data` instead of becoming a child of the PopupWindow itself.
    default property alias contents: container.data

    anchor.window: panelWindow
    visible: false
    color: "transparent"

    Rectangle {
        id: panel
        anchors.fill: parent
        color: Theme.popupBg
        radius: 10
        border.color: Theme.border
        border.width: 1

        opacity: 0
        scale: 0.96
        transformOrigin: Item.Center

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animFast
                easing.type: Easing.OutCubic
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: Theme.animFast
                easing.type: Easing.OutCubic
            }
        }

        Item {
            id: container
            anchors.fill: parent
            anchors.margins: popout.padding
        }
    }

    // Recompute anchor position every time the popout becomes visible.
    // We pick a reference X on the parent (left / center / right) and subtract
    // the equivalent offset on the popout, so the chosen edges line up.
    // Y is always pinned to the bottom of the parent item.
    onVisibleChanged: {
        if (!visible) {
            panel.opacity = 0;
            panel.scale = 0.96;
            return;
        }

        const localX = alignment === "center" ? parentItem.width / 2 : alignment === "right" ? parentItem.width : 0;
        const popoutOffset = alignment === "center" ? container.width / 2 : alignment === "right" ? container.width : 0;

        anchor.rect.x = parentItem.mapToItem(panelWindow.contentItem, localX, 0).x - popoutOffset;
        anchor.rect.y = parentItem.mapToItem(panelWindow.contentItem, 0, parentItem.height).y;

        panel.opacity = 1;
        panel.scale = 1;
    }
}
