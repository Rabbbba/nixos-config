import QtQuick
import Quickshell
import "../modules"

PopupWindow {
    id: popout

    required property Item parentItem
    required property var panelWindow

    // Slot de contenu : tout enfant déclaré dans un Popout {} consommateur
    // atterrit dans `container.data` au lieu d'être enfant direct de la fenêtre.
    default property alias contents: container.data

    anchor.window: panelWindow
    visible: false
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Theme.bg1
        radius: 10
        border.color: Theme.bg3
        border.width: 1

        Item {
            id: container
            anchors.fill: parent
            anchors.margins: 14
        }
    }

    onVisibleChanged: {
        if (visible) {
            anchor.rect.x = parentItem.mapToItem(panelWindow.contentItem, parentItem.width / 2, 0).x - popout.width / 2;
            anchor.rect.y = parentItem.mapToItem(panelWindow.contentItem, 0, parentItem.height).y;
        }
    }
}
