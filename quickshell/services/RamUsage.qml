pragma Singleton
import QtQuick
import NativeSensors

/**
 * @brief Singleton exposing RAM and swap usage parsed from `/proc/meminfo`.
 *
 * Polls `/proc/meminfo` every 1 s. `ramPercent` is computed via
 * `(MemTotal - MemAvailable) / MemTotal` — the kernel-recommended formula
 * (accounts for reclaimable caches, unlike `MemFree`).
 */
QtObject {
    id: root

    property NativeRam _ram: NativeRam {}
    /** Used RAM as a percentage (0–100), based on MemTotal - MemAvailable. */
    readonly property real ramPercent: _ram.ramPercent
    /** Used RAM in kB (MemTotal - MemAvailable). */
    readonly property real ramUsedKb: _ram.ramUsedKb
    /** Total RAM in kB. */
    readonly property real ramTotalKb: _ram.ramTotalKb
    /** Memory used by buffers in kB. */
    readonly property real ramBuffersKb: _ram.ramBuffersKb
    /** Memory used by the page cache in kB. */
    readonly property real ramCachedKb: _ram.ramCachedKb
    /** Used swap in kB (SwapTotal - SwapFree). */
    readonly property real swapUsedKb: _ram.swapUsedKb
    /** Total swap in kB. */
    readonly property real swapTotalKb: _ram.swapTotalKb

    readonly property int _historyLength: 60
    /**
     * Rolling history of the last 60 @ref ramPercent samples (one per
     * 1 s tick → 60 s window). Read directly by the Sparkline component.
     */
    property var ramHistory: []

    function _pushHistory(arr, value) {
        const next = arr.slice();
        next.push(value);
        if (next.length > root._historyLength)
            next.shift();
        return next;
    }

    property Connections _ramConn: Connections {
        target: root._ram
        function onRamChanged() {
            root.ramHistory = root._pushHistory(root.ramHistory, root.ramPercent);
        }
    }
}
