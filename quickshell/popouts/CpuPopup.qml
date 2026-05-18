import QtQuick
import "../services"
import "../modules"
import "../components"

/**
 * @brief CPU popup body — global usage, sparkline, per-core bars, Tctl, load avg.
 *
 * Reads from the @ref services::CpuUsage singleton. Meant to be placed inside
 * a @ref components::PopoutItem (sized by the call site).
 */
Item {
    id: root
    anchors.fill: parent

    /**
     * Format a load-average value as a string with two decimal places.
     * @param n Numeric load value.
     */
    function fmt(n: real): string {
        return n.toFixed(2);
    }

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16
        Item {
            width: parent.width
            height: 24
            SectionHeader {
                text: "CPU"
            }
            StyledText {
                text: Math.round(CpuUsage.cpuPercent) + " %"
                anchors.right: parent.right
            }
        }
        Sparkline {
            width: parent.width
            values: CpuUsage.cpuHistory
            color: Theme.accent
        }
        Row {
            width: parent.width
            spacing: 2
            Repeater {
                model: CpuUsage.cpuCoresPercent
                Rectangle {
                    id: bar

                    required property real modelData
                    required property int index

                    width: (parent.width - (CpuUsage.cpuCoresPercent.length - 1) * 2) / CpuUsage.cpuCoresPercent.length
                    height: 60
                    color: Theme.moduleBg
                    radius: 2

                    Rectangle {
                        anchors {
                            bottom: parent.bottom
                            left: parent.left
                            right: parent.right
                        }
                        height: parent.height * (bar.modelData / 100)
                        color: Theme.accent
                        radius: 2

                        Behavior on height {
                            NumberAnimation {
                                duration: 500
                                easing.type: Easing.Linear
                            }
                        }
                    }
                }
            }
        }
        Row {
            spacing: 12

            StyledText {
                text: "Tctl: " + Math.round(CpuUsage.cpuTemp) + " °C"
                color: Theme.textMuted
                font.bold: true
            }
            StyledText {
                text: "Load:"
                color: Theme.textMuted
            }
            StyledText {
                text: "1m:" + root.fmt(CpuUsage.loadAverage.l1)
                color: Theme.textMuted
            }
            StyledText {
                text: "5m:" + root.fmt(CpuUsage.loadAverage.l5)
                color: Theme.textMuted
            }
            StyledText {
                text: "15m:" + root.fmt(CpuUsage.loadAverage.l15)
                color: Theme.textMuted
            }
        }
    }
}
