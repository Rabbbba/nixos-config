import QtQuick
import Quickshell
import "../modules"

PopupWindow {
    id: tooltip
    required property Item parentItem
    required property var panelWindow
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
