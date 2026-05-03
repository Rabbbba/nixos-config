import QtQuick
import "../modules"
import "../components"

// Static month view: header + weekday row + 7-column grid of day cells.
// Today's cell is highlighted in the theme accent.
// Lives inside the Clock module's Popout.
Item {
    id: root
    property date now: new Date()

    readonly property int year: now.getFullYear()
    readonly property int month: now.getMonth()
    readonly property int today: now.getDate()

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
            text: Qt.locale("fr_FR").toString(root.now, "MMMM yyyy")
            font.bold: true
            font.pixelSize: Theme.fontSizeMd
        }

        Grid {
            columns: 7
            spacing: root.cellSpacing

            // Weekday headers (French initials, week starts Monday).
            Repeater {
                model: ["L", "M", "M", "J", "V", "S", "D"]
                StyledText {
                    width: root.cellSize
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    color: Theme.textMuted
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
                    width: root.cellSize
                    horizontalAlignment: Text.AlignHCenter
                    text: index + 1
                    color: (index + 1) === root.today ? Theme.accent : Theme.text
                    font.bold: (index + 1) === root.today
                }
            }
        }
    }
}
