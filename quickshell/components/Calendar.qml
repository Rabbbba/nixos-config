import QtQuick
import "../modules"

Item {
    id: root
    property date now: new Date()

    readonly property int year: now.getFullYear()
    readonly property int month: now.getMonth()
    readonly property int today: now.getDate()

    // Lundi = 0, dimanche = 6 (recalage depuis JS où dimanche = 0)
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
            text: Qt.formatDate(root.now, "MMMM yyyy")
            font.bold: true
            font.pixelSize: Theme.fontSizeMd
        }

        Grid {
            columns: 7
            spacing: root.cellSpacing

            // En-têtes jours de la semaine
            Repeater {
                model: ["L", "M", "M", "J", "V", "S", "D"]
                StyledText {
                    width: root.cellSize
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    color: Theme.fg4
                }
            }

            // Cases vides avant le 1er du mois
            Repeater {
                model: root.firstDayOffset
                Item {
                    width: root.cellSize
                    height: root.cellSize
                }
            }

            // Jours du mois
            Repeater {
                model: root.daysInMonth
                StyledText {
                    width: root.cellSize
                    horizontalAlignment: Text.AlignHCenter
                    text: index + 1
                    color: (index + 1) === root.today ? Theme.yellow : Theme.fg1
                    font.bold: (index + 1) === root.today
                }
            }
        }
    }
}
