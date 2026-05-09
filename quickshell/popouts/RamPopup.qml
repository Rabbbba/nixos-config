import QtQuick
import "../services"
import "../modules"
import "../components"

/**
 * @brief RAM popup body — memory usage, sparkline, buffers/cached, and swap.
 *
 * Reads from the @ref services::RamUsage singleton. Meant to be placed inside
 * a @ref components::Popout (sized by the call site).
 */
Item {
    id: root
    anchors.fill: parent

    /**
     * Convert a kB value to GiB with one decimal.
     * @param kb Value in kB (as exposed by `/proc/meminfo`).
     */
    function kbToGib(kb: real): string {
        return (kb / 1048576).toFixed(1);
    }

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        Column {
            width: parent.width
            spacing: 6

            SectionHeader {
                text: "Memory"
            }

            KeyValueRow {
                width: parent.width
                label: root.kbToGib(RamUsage.ramUsedKb) + " GiB / " + root.kbToGib(RamUsage.ramTotalKb) + " GiB"
                value: "(" + Math.round(RamUsage.ramPercent) + "%)"
            }

            ProgressBar {
                width: parent.width
                value: RamUsage.ramTotalKb > 0 ? RamUsage.ramUsedKb / RamUsage.ramTotalKb : 0
            }

            Sparkline {
                width: parent.width
                values: RamUsage.ramHistory
                color: Theme.accent
            }

            StyledText {
                text: "Buffers + Cached: " + root.kbToGib(RamUsage.ramBuffersKb + RamUsage.ramCachedKb) + " GiB"
                color: Theme.textMuted
                font.pixelSize: Theme.fontSizeMd - 2
            }
        }

        Column {
            width: parent.width
            spacing: 6

            SectionHeader {
                text: "Swap"
            }

            KeyValueRow {
                width: parent.width
                label: RamUsage.swapTotalKb > 0 ? root.kbToGib(RamUsage.swapUsedKb) + " GiB / " + root.kbToGib(RamUsage.swapTotalKb) + " GiB" : "no swap configured"
                value: ""
            }

            ProgressBar {
                width: parent.width
                value: RamUsage.swapTotalKb > 0 ? RamUsage.swapUsedKb / RamUsage.swapTotalKb : 0
            }
        }
    }
}
