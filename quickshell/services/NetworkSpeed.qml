pragma Singleton
import QtQuick
import NativeSensors
import "History.js" as History

/**
 * @brief Singleton exposing active-interface network throughput.
 *
 * Download/upload speeds (KiB/s) come from the native NativeNetwork plugin,
 * which resolves the routable interface via /proc/net/route and reads the
 * sysfs byte counters in C++. This singleton only binds those values and
 * keeps a rolling 60-sample history per direction for the sparklines.
 */
QtObject {
    id: root

    property NativeNetwork _net: NativeNetwork {}
    /** @brief Current download speed in kiB/s (1024-based) */
    readonly property real downloadKbps: _net.downloadKbps

    /** @brief Current upload speed in kiB/s (1024 based) */
    readonly property real uploadKbps: _net.uploadKbps

    /** @brief Rolling history of the last 60 downloadKbps samples (graph rendering). */
    property var downloadHistory: []

    /** @brief Rolling history of the last 60 uploadKbps samples (graph rendering). */
    property var uploadHistory: []

    readonly property int _pollInterval: 2000

    /** @brief Maximum number of samples kept in the rolling sparkline history window. */
    readonly property int _historyLength: 60

    /** @brief Format a KiB/s speed as "Mb"/"Gb" (decimal bits, base 1000) — the
     *  convention ISPs and Steam use, so the bar matches what they advertise.
     *  Integer "Mb" below 1000 Mbps, else "Gb" with one decimal. Lowercase `b`
     *  marks bits, not bytes.
     *  @param kbps Speed in KiB/s (1024-based bytes per second).
     */
    function formatSpeed(kbps: real): string {
        // Guard against transient NaN/negative during interface toggles
        // so the bar never renders "NaNGb".
        if (!Number.isFinite(kbps) || kbps < 0)
            return "0Mb";
        // KiB/s → bytes/s → bits/s → Mbps (decimal, base 1000).
        const mbps = kbps * 1024 * 8 / 1000000;
        const rounded = Math.round(mbps);
        if (rounded < 1000)
            return rounded + "Mb";
        return (mbps / 1000).toFixed(1) + "Gb";
    }

    property Timer _historyTimer: Timer {
        running: true
        interval: root._pollInterval
        repeat: true
        onTriggered: {
            root.downloadHistory = History.push(root.downloadHistory, root._net.downloadKbps, root._historyLength);
            root.uploadHistory = History.push(root.uploadHistory, root._net.uploadKbps, root._historyLength);
        }
    }
}
