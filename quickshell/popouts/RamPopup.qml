import QtQuick
import "../services"
import "../modules"
import "../components"

Item {
    id: root
    anchors.fill: parent

    function kbToGib(kb) {
        return (kb / 1048576).toFixed(1);
    }

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16
        Column {
            width: parent.width
            spacing: 6

            StyledText {
                text: "Memory"
                font.bold: true
                color: Theme.text
            }

            Item {
                width: parent.width
                height: 18

                StyledText {
                    anchors.left: parent.left
                    text: root.kbToGib(SystemUsage.ramUsedKb) + " GiB / " + root.kbToGib(SystemUsage.ramTotalKb) + " GiB"
                }
                StyledText {
                    anchors.right: parent.right
                    text: "(" + Math.round(SystemUsage.ramPercent) + "%)"
                    color: Theme.textMuted
                }
            }

            Rectangle {
                width: parent.width
                height: 8
                color: Theme.moduleBg
                radius: 4

                Rectangle {
                    anchors.left: parent.left
                    height: parent.height
                    width: parent.width * (SystemUsage.ramUsedKb / SystemUsage.ramTotalKb)
                    color: Theme.accent
                    radius: 4
                }
            }

            StyledText {
                text: "Buffers + Cached: " + root.kbToGib(SystemUsage.ramBuffersKb + SystemUsage.ramCachedKb) + " GiB"
                color: Theme.textMuted
                font.pixelSize: Theme.fontSizeMd - 2
            }
        }

        Column {
            width: parent.width
            spacing: 6

            StyledText {
                text: "Swap"
                font.bold: true
                color: Theme.text
            }

            Item {
                width: parent.width
                height: 18

                StyledText {
                    anchors.left: parent.left
                    text: SystemUsage.swapTotalKb > 0 ? root.kbToGib(SystemUsage.swapUsedKb) + " GiB / " + root.kbToGib(SystemUsage.swapTotalKb) + " GiB" : "no swap configured"
                }
            }

            Rectangle {
                width: parent.width
                height: 8
                color: Theme.moduleBg
                radius: 4

                Rectangle {
                    anchors.left: parent.left
                    height: parent.height
                    width: SystemUsage.swapTotalKb > 0 ? parent.width * (SystemUsage.swapUsedKb / SystemUsage.swapTotalKb) : 0
                    color: Theme.accent
                    radius: 4
                }
            }
        }
    }
}
