pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../../components"

/**
 * @brief StatusNotifier system tray — renders one icon per registered tray item.
 *
 * Left-click activates the item, right-click triggers the secondary action.
 * Hovering an icon for 300 ms shows a tooltip combining the item's title and
 * description. The whole row is hidden when no tray items are registered.
 */
Item {
    id: root

    /** Reference to the @c PanelWindow hosting this tray (needed for tooltips). */
    property var panelWindow: null

    /** Side length of each tray icon in pixels. */
    readonly property int iconSize: 21
    /** Horizontal spacing between tray icons in pixels. */
    readonly property int itemSpacing: 8

    /** Items whose id or title matches any pattern here are hidden from the tray.
     *  Use this to suppress items already shown by dedicated bar modules (e.g. Network, Bluetooth).
     */
    property list<string> excludedPatterns: ["blueman"       // Blueman Bluetooth manager
        , "bluetooth"     // Any other Bluetooth tray item
        , "network"       // NetworkManager applet
        , "nm-"           // nm-applet variants
        , "wired"          // Wired connection indicator
    ]

    /**
    * Checks whether a tray item should be hidden based on @p excludedPatterns.
    * @param item The SystemTrayItem to check.
    */
    function isExcluded(item: SystemTrayItem) {
        const id = (item.id || "").toLowerCase();
        const title = (item.title || "").toLowerCase();
        for (const pattern of root.excludedPatterns) {
            if (id.includes(pattern.toLowerCase()) || title.includes(pattern.toLowerCase()))
                return true;
        }
        return false;
    }

    visible: SystemTray.items.values.length > 0
    implicitHeight: 30
    implicitWidth: row.implicitWidth

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: root.itemSpacing

        Repeater {
            model: SystemTray.items
            delegate: Item {
                id: cell

                required property SystemTrayItem modelData

                visible: !root.isExcluded(modelData)
                width: root.iconSize
                height: root.iconSize

                readonly property string tooltipText: {
                    const t = cell.modelData.tooltipTitle || cell.modelData.title || cell.modelData.id || "";
                    const d = cell.modelData.tooltipDescription || "";
                    return d !== "" ? t + " — " + d : t;
                }

                IconImage {
                    id: img
                    anchors.fill: parent
                    asynchronous: true
                    source: cell.modelData.icon
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: e => {
                        switch (e.button) {
                        case Qt.LeftButton:
                            cell.modelData.activate();
                            break;
                        case Qt.RightButton:
                            {
                                const p = cell.mapToItem(root.panelWindow.contentItem, e.x, e.y);
                                if (cell.modelData.hasMenu)
                                    cell.modelData.display(root.panelWindow, p.x, p.y);
                                else
                                    cell.modelData.secondaryActivate();
                                break;
                            }
                        }
                    }
                    onEntered: if (cell.tooltipText !== "")
                        ttTimer.start()
                    onExited: {
                        ttTimer.stop();
                        tt.visible = false;
                    }
                }

                Timer {
                    id: ttTimer
                    interval: 300
                    onTriggered: tt.visible = true
                }

                Tooltip {
                    id: tt
                    parentItem: cell
                    panelWindow: root.panelWindow
                    text: cell.tooltipText
                }
            }
        }
    }
}
