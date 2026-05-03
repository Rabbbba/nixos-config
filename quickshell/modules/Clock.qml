import QtQuick
import "../components"

// Center-bar clock, ticks every minute. Click toggles a Calendar popout.
ModuleWrapper {
    id: root
    bgIdle: Theme.yellow
    bgHover: Theme.bg2

    property var panelWindow: null

    StyledText {
        property date now: new Date()
        color: root.hovered ? Theme.fg1 : Theme.bg1
        font.pixelSize: Theme.fontSizeLg
        font.bold: true
        text: Qt.formatDateTime(now, "HH:mm dd/MM")
        // 60s is enough — the displayed precision is the minute.
        Timer {
            interval: 60000
            running: true
            repeat: true
            onTriggered: parent.now = new Date()
        }
    }

    Popout {
        id: popup
        parentItem: root
        panelWindow: root.panelWindow
        implicitWidth: 280
        implicitHeight: 220
        alignement: "center"

        Calendar {
            anchors.centerIn: parent
        }
    }

    onClicked: popup.visible = !popup.visible
}
