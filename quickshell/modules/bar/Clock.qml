// qmllint disable missing-property
import QtQuick
import "../../components"
import "../../services"

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

    bgIdle: Theme.color.accent
    bgHover: Theme.color.moduleBg

    tooltip: Qt.locale().toString(now, "dddd d MMMM yyyy")

    StyledText {

        color: root.hovered ? Theme.color.text : Theme.color.popupBg
        font.pixelSize: Theme.font.sizeLg
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

    onClicked: Visibilities.toggle("calendar")
}
