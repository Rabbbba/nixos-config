import QtQuick
import "../services"
import "../modules"
import "../components"

Item {
    id: root
    anchors.fill: parent

    function fmt(n) {
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
                text: Math.round(SystemUsage.cpuPercent) + " %"
                anchors.right: parent.right
            }
        }
        Row {
            width: parent.width
            spacing: 2
            Repeater {
                model: SystemUsage.cpuCoresPercent
                Rectangle {
                    id: bar

                    required property real modelData
                    required property int index

                    width: (parent.width - (SystemUsage.cpuCoresPercent.length - 1) * 2) / SystemUsage.cpuCoresPercent.length
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
                text: "Load:"
                color: Theme.textMuted
            }
            StyledText {
                text: "1m:" + root.fmt(SystemUsage.loadAverage.l1)
                color: Theme.textMuted
            }
            StyledText {
                text: "5m:" + root.fmt(SystemUsage.loadAverage.l5)
                color: Theme.textMuted
            }
            StyledText {
                text: "15m:" + root.fmt(SystemUsage.loadAverage.l15)
                color: Theme.textMuted
            }
        }
    }
}
