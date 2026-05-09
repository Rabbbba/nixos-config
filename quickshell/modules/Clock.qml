import QtQuick
import "../components"
import "../popouts"
import "../services"

/**
 * @brief Center-bar clock — ticks every minute and toggles a calendar popout on click.
 *
 * Display format: `HH:mm dd/MM`. Tooltip shows the full localized date.
 * Clicking opens the @c CalendarPopup popout.
 */
ModuleWrapper {
    id: root

    /** Current date/time displayed by the clock (refreshed every 60 s). */
    property date now: new Date()

    bgIdle: Theme.accent
    bgHover: Theme.moduleBg

    tooltip: Qt.locale().toString(now, "dddd d MMMM yyyy")

    StyledText {

        color: root.hovered ? Theme.text : Theme.popupBg
        font.pixelSize: Theme.fontSizeLg
        font.bold: true
        text: Qt.formatDateTime(root.now, "HH:mm dd/MM")
        // 60 s is enough — the displayed precision is the minute.
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
