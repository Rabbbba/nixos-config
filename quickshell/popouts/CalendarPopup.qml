pragma ComponentBehavior: Bound
import QtQuick
import "../services"
import "../components"

/**
 * @brief Static month view: header + weekday row + 7-column grid of day cells.
 *
 * Today's cell is highlighted in the theme accent. Lives inside the
 * @ref modules::bar::Clock module's popout. Refreshes once a minute (so a session
 * spanning midnight rolls over without restart).
 */
Item {
    id: root
    anchors.fill: parent

    /** Reference date — drives @ref year, @ref month, @ref today. Refreshed every 60 s. */
    property date now: new Date()

    /** Calendar year being displayed (derived from @ref now). */
    readonly property int year: now.getFullYear()
    /** Calendar month being displayed, 0-indexed (derived from @ref now). */
    readonly property int month: now.getMonth()
    /** Day-of-month for today, used to highlight the right cell. */
    readonly property int today: now.getDate()

    Timer {
        interval: 60000
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    // Monday = 0, Sunday = 6. JS's getDay() puts Sunday at 0, so shift by +6 mod 7.
    readonly property int firstDayOffset: ((new Date(year, month, 1).getDay()) + 6) % 7
    readonly property int daysInMonth: new Date(year, month + 1, 0).getDate()

    readonly property int cellSize: 28
    readonly property int cellSpacing: 4

    implicitWidth: 7 * cellSize + 6 * cellSpacing
    implicitHeight: column.implicitHeight

    Column {
        id: column
        anchors.centerIn: parent
        spacing: 8

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.locale().toString(root.now, "MMMM yyyy")
            font.bold: true
            font.pixelSize: Theme.font.sizeMd
        }

        Grid {
            columns: 7
            spacing: root.cellSpacing

            // Weekday headers — narrow names from the system locale, week starts Monday.
            // Qt's standaloneDayName uses 0=Sunday..6=Saturday, so map (idx+1)%7.
            Repeater {
                model: 7
                StyledText {
                    required property int index

                    width: root.cellSize
                    height: root.cellSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: Qt.locale().standaloneDayName((index + 1) % 7, Locale.NarrowFormat).toUpperCase()
                    color: Theme.color.textMuted
                }
            }

            // Empty cells padding the grid up to the 1st of the month.
            Repeater {
                model: root.firstDayOffset
                Item {
                    width: root.cellSize
                    height: root.cellSize
                }
            }

            // Day cells.
            Repeater {
                model: root.daysInMonth
                StyledText {
                    required property int index

                    width: root.cellSize
                    height: root.cellSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: index + 1
                    color: (index + 1) === root.today ? Theme.color.accent : Theme.color.text
                    font.bold: (index + 1) === root.today
                }
            }
        }
    }
}
