import QtQuick
import Quickshell
import "../modules"

// Generic popout window anchored under a bar item.
// Consumers write:  Popout { parentItem: someItem; panelWindow: bar; ... <content> }
// and the content lands inside `container` (padded), not as a direct child of the
// PopupWindow. Pop-in animation: opacity 0→1 + scale 0.96→1 on visible toggle.
PopupWindow {
    id: popout

    required property Item parentItem
    required property var panelWindow

    property int padding: 14

    // Horizontal alignment of the popout relative to the parent item:
    // "left"   → popout's left edge aligns with parent's left
    // "center" → popout horizontally centered on the parent
    // "right"  → popout's right edge aligns with parent's right
    property string alignement: "center"

    // Default property: anything declared inside a Popout {} block is reparented
    // into `container.data` instead of becoming a child of the PopupWindow itself.
    default property alias contents: container.data

    anchor.window: panelWindow
    visible: false
    color: "transparent"

    Rectangle {
        id: panel
        anchors.fill: parent
        color: Theme.bg1
        radius: 10
        border.color: Theme.bg3
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

        const localX = alignement === "center" ? parentItem.width / 2 : alignement === "right" ? parentItem.width : 0;
        const popoutOffset = alignement === "center" ? popout.implicitWidth / 2 : alignement === "right" ? popout.implicitWidth : 0;

        anchor.rect.x = parentItem.mapToItem(panelWindow.contentItem, localX, 0).x - popoutOffset;
        anchor.rect.y = parentItem.mapToItem(panelWindow.contentItem, 0, parentItem.height).y;

        panel.opacity = 1;
        panel.scale = 1;
    }
}
