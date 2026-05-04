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

            SectionHeader { text: "Memory" }

            KeyValueRow {
                width: parent.width
                label: root.kbToGib(SystemUsage.ramUsedKb) + " GiB / " + root.kbToGib(SystemUsage.ramTotalKb) + " GiB"
                value: "(" + Math.round(SystemUsage.ramPercent) + "%)"
            }

            ProgressBar {
                width: parent.width
                value: SystemUsage.ramUsedKb / SystemUsage.ramTotalKb
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

            SectionHeader { text: "Swap" }

            KeyValueRow {
                width: parent.width
                label: SystemUsage.swapTotalKb > 0
                    ? root.kbToGib(SystemUsage.swapUsedKb) + " GiB / " + root.kbToGib(SystemUsage.swapTotalKb) + " GiB"
                    : "no swap configured"
                value: ""
            }

            ProgressBar {
                width: parent.width
                value: SystemUsage.swapTotalKb > 0 ? SystemUsage.swapUsedKb / SystemUsage.swapTotalKb : 0
            }
        }
    }
}
