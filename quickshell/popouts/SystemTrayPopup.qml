pragma ComponentBehavior: Bound
// qmllint disable missing-property
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import "../components"
import "../services"

/**
 * @brief System tray menu popup — shows the DBusMenu of the clicked tray icon.
 *
 * Designed as a plain Item to be hosted inside a PopoutItem in shell.qml.
 * Reads the active menu handle from the SystemTray bar module and renders
 * its items via QsMenuOpener, matching the look and feel of the other popouts
 * (WifiPopup, BluetoothPopup, etc.).
 */
Item {
    id: root
    anchors.fill: parent

    /** The active DBusMenu handle set by SystemTray on right-click. */
    property var currentMenu: null

    /**
     * Natural height of the column — exposed so the hosting PopoutItem can
     * size itself to the actual menu content instead of a fixed slot.
     */
    readonly property real preferredHeight: menuColumn.implicitHeight

    QtObject {
        id: menuOpener
        property var currentMenu: root.currentMenu
        property QsMenuOpener opener: QsMenuOpener {
            menu: menuOpener.currentMenu
        }
    }

    Column {
        id: menuColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 2

        Repeater {
            model: menuOpener.opener.children

            delegate: Item {
                id: menuItem
                required property var modelData

                width: parent.width
                height: modelData.isSeparator ? 8 : 32

                HoverHandler {
                    id: hoverHandler
                    enabled: modelData.enabled && !modelData.isSeparator
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -4
                    radius: 6
                    color: hoverHandler.hovered ? Theme.color.popupBg : Theme.color.moduleBg

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.anim.fast
                        }
                    }
                }

                StyledText {
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.isSeparator ? "" : modelData.text
                    color: modelData.enabled ? Theme.color.text : Theme.color.textMuted
                    font.pixelSize: Theme.font.sizeSm
                    elide: Text.ElideRight
                    width: parent.width - 8
                    horizontalAlignment: Text.AlignLeft
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    height: 1
                    color: Theme.color.border
                    visible: modelData.isSeparator
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: modelData.enabled && !modelData.isSeparator
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        modelData.triggered();
                        Visibilities.close();
                    }
                }
            }
        }
    }
}
