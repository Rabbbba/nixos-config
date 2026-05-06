pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../components"

Item {
    id: root
    property var panelWindow: null

    readonly property int iconSize: 21
    readonly property int itemSpacing: 8

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
                        if (e.button === Qt.LeftButton)
                            modelData.activate();
                        else
                            modelData.secondaryActivate();
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
