import QtQuick
import Quickshell
import "../modules"

PopupWindow {
    id: popout

    required property Item parentItem
    required property var panelWindow

    anchor.window: panelWindow
    visible: false
    color: Theme.bg1

    onVisibleChanged: {
        if (visible) {
            anchor.rect.x = parentItem.mapToItem(panelWindow.contentItem, 0, 0).x;
            anchor.rect.y = parentItem.mapToItem(panelWindow.contentItem, 0, parentItem.height).y;
        }
    }
}
