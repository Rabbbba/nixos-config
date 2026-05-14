pragma Singleton
import QtQuick
import Quickshell.Io

/**
 * @brief Singleton that monitors active network interface throughput.
 *
 * Reads cumulative byte counters from `/sys/class/net/<iface>/statistics/`
 * every 2 s, computes delta-based upload/download speed in KiB/s, and
 * maintains a rolling 60-sample history for graph rendering.
 *
 * The active interface is determined from the default route table
 * (`ip route show default`), not from operstate — so it correctly picks
 * the routable interface even when several interfaces are up at once.
 */
QtObject {
    id: root

    /** @brief Current download speed in kiB/s (1024-based) */
    property real downloadKbps: 0

    /** @brief Current upload speed in kiB/s (1024 based) */
    property real uploadKbps: 0

    /** @brief Rolling history of the last 60 downloadKbps samples (graph rendering). */
    property var downloadHistory: []

    /** @brief Rolling history of the last 60 uploadKbps samples (graph rendering). */
    property var uploadHistory: []

    /** @brief Cumulative rx_bytes counter from the previous poll tick. Used to compute delta for download speed. */
    property real _prevRx: 0

    /** @brief Cumulative tx_bytes counter from the previous poll tick. Used to compute delta for upload speed. */
    property real _prevTx: 0

    /** @brief Number of ticks elapsed since service started. Skips first tick when counters are zero. */
    property int _tickCount: 0

    readonly property int _pollInterval: 2000

    /** @brief Maximum number of samples kept in the rolling sparkline history window. */
    readonly property int _historyLength: 60

    /** @brief Append a value to a rolling array, dropping oldest if over limit.
     *  @param arr The source array (must be a var).
     *  @param value The numeric value to append.
     *  @return A new array with the value added and oldest dropped if necessary.
     */
    function _pushHistory(arr, value) {
        const next = arr.slice();
        next.push(value);
        if (next.length > _historyLength) {
            next.shift();
        }
        return next;
    }

    /** @brief Clamp a speed value to non-negative.
     *  Skips the tick silently when delta is negative (interface change).
     *  @param speed The speed value in KiB/s.
     *  @return The clamped value, or -1 if the tick should be skipped.
     */
    function _clamp(speed) {
        if (speed < 0)
            return -1;
        else
            return speed;
    }

    /** @brief Format a speed value in KiB/s as a compact integer string in MiB/s or GiB/s.
     *
     *  Sub-MiB values round to "0M" — at the time / s scale relevant for a
     *  desktop status bar, traffic below ~500 KiB/s is keepalive / DNS
     *  background noise that we would rather hide than display as "0.x K".
     *  Above 1 GiB/s the unit switches to "G".
     *  @param kbps The speed value in KiB/s (1024-based).
     */
    function formatSpeed(kbps: real): string {
        if (kbps < 1048576)
            return Math.round(kbps / 1024) + "M";
        return Math.round(kbps / 1048576) + "G";
    }

    /** @brief Pending rx_bytes value received from the first line of Process output (64-bit safe). */
    property real _pendingRx: 0

    /** @brief Pending tx_bytes value received from the second line of Process output (64-bit safe). */
    property real _pendingTx: 0

    /** @brief Line counter within a single tick (0 = waiting for rx, 1 = waiting for tx). Resets to 0 after both lines received. */
    property int _lineCount: 0

    property Process _netStatsReader: Process {
        running: true
        command: ["sh", "-c", "iface=$(ip route show default 2>/dev/null | awk '{print $5}'); [ -n \"$iface\" ] && cat /sys/class/net/$iface/statistics/rx_bytes /sys/class/net/$iface/statistics/tx_bytes"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const value = parseInt(data.trim());

                if (root._lineCount === 0) {
                    root._pendingRx = value;
                    root._lineCount = 1;
                    return;
                }

                if (root._lineCount === 1) {
                    root._pendingTx = value;
                    root._lineCount = 0;

                    root._tickCount++;
                    if (root._tickCount === 1)
                        return;

                    const deltaRx = root._pendingRx - root._prevRx;
                    const deltaTx = root._pendingTx - root._prevTx;
                    const downloadSpeed = (deltaRx / root._pollInterval * 1000) / 1024;
                    const uploadSpeed = (deltaTx / root._pollInterval * 1000) / 1024;

                    const clampedDown = root._clamp(downloadSpeed);
                    const clampedUp = root._clamp(uploadSpeed);

                    if (clampedDown >= 0 && clampedUp >= 0) {
                        root.downloadKbps = clampedDown;
                        root.uploadKbps = clampedUp;
                        root.downloadHistory = root._pushHistory(root.downloadHistory, clampedDown);
                        root.uploadHistory = root._pushHistory(root.uploadHistory, clampedUp);
                    }

                    root._prevRx = root._pendingRx;
                    root._prevTx = root._pendingTx;
                }
            }
        }
    }

    property Timer _pollTimer: Timer {
      running: true
      interval: root._pollInterval
      repeat: true
      triggeredOnStart: true
      onTriggered: {
        _netStatsReader.running = false;
        _netStatsReader.running = true;
      }
    }
}
