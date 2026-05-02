import QtQuick
import Quickshell
import "../modules"

PopupWindow {
    id: popout

    required property Item parentItem
    required property var panelWindow

    property int padding: 14

    // "left" | "center"a | "right"
    property string alignement: "center"

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
            anchors.margins: popout.padding
        }
    }

    onVisibleChanged: {
        if (!visible) {
            return;
        }

        const localX = alignement === "center" ? parentItem.width / 2 : alignement === "right" ? parentItem.width : 0;
        const popoutOffset = alignement === "center" ? popout.implicitWidth / 2 : alignement === "right" ? popout.implicitWidth : 0;

        anchor.rect.x = parentItem.mapToItem(panelWindow.contentItem, localX, 0).x - popoutOffset;
        anchor.rect.y = parentItem.mapToItem(panelWindow.contentItem, 0, parentItem.height).y;
    }
}
