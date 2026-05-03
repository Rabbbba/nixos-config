import QtQuick
import "../components"
import "../popouts"
import "../services"

// Center-bar clock, ticks every minute. Click toggles a Calendar popout.
ModuleWrapper {
    id: root
    bgIdle: Theme.accent
    bgHover: Theme.moduleBg

    property var panelWindow: null

    StyledText {
        property date now: new Date()
        color: root.hovered ? Theme.text : Theme.popupBg
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

        visible: Visibilities.current === "calendar"

        CalendarPopup {
            anchors.centerIn: parent
        }
    }

    onClicked: Visibilities.toggle("calendar")
}
