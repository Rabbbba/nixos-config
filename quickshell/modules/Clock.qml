import QtQuick
import "../components"
import "../popouts"
import "../services"

// Center-bar clock, ticks every minute. Click toggles a Calendar popout.
ModuleWrapper {
    id: root
    property date now: new Date()

    bgIdle: Theme.accent
    bgHover: Theme.moduleBg

    tooltip: Qt.locale().toString(now, "dddd d MMMM yyyy")

    StyledText {

        color: root.hovered ? Theme.text : Theme.popupBg
        font.pixelSize: Theme.fontSizeLg
        font.bold: true
        text: Qt.formatDateTime(root.now, "HH:mm dd/MM")
        // 60s is enough — the displayed precision is the minute.
        Timer {
            interval: 60000
            running: true
            repeat: true
            onTriggered: root.now = new Date()
        }
    }

    ModulePopout {
        wrapper: root
        name: "calendar"
        implicitWidth: 280
        implicitHeight: 220
        alignment: "center"

        CalendarPopup {
            anchors.centerIn: parent
        }
    }

    onClicked: Visibilities.toggle("calendar")
}
