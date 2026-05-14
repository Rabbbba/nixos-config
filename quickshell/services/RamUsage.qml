pragma Singleton
import QtQuick
import Quickshell.Io
import "."

/**
 * @brief Singleton exposing RAM and swap usage parsed from `/proc/meminfo`.
 *
 * Polls `/proc/meminfo` every 500 ms. `ramPercent` is computed via
 * `(MemTotal - MemAvailable) / MemTotal` — the kernel-recommended formula
 * (accounts for reclaimable caches, unlike `MemFree`).
 */
QtObject {
    id: root

    /** Used RAM as a percentage (0–100), based on MemTotal - MemAvailable. */
    property real ramPercent: 0
    /** Used RAM in kB (MemTotal - MemAvailable). */
    property real ramUsedKb: 0
    /** Total RAM in kB. */
    property real ramTotalKb: 0
    /** Memory used by buffers in kB. */
    property real ramBuffersKb: 0
    /** Memory used by the page cache in kB. */
    property real ramCachedKb: 0
    /** Used swap in kB (SwapTotal - SwapFree). */
    property real swapUsedKb: 0
    /** Total swap in kB. */
    property real swapTotalKb: 0

    readonly property int _historyLength: 60
    /**
     * Rolling history of the last 60 @ref ramPercent samples (one per
     * 500 ms tick). Read directly by the Sparkline component.
     */
    property var ramHistory: []

    function _pushHistory(arr, value) {
        const next = arr.slice();
        next.push(value);
        if (next.length > root._historyLength)
            next.shift();
        return next;
    }

    property FileView _ramFile: FileView {
        id: ramFile
        path: "/proc/meminfo"
        blockLoading: true

        onLoaded: {
            const content = ramFile.text();
            const m = re => content.match(re);
            const tot = m(/MemTotal:\s+(\d+)/);
            const av = m(/MemAvailable:\s+(\d+)/);
            const buf = m(/Buffers:\s+(\d+)/);
            const cac = m(/Cached:\s+(\d+)/);
            const stot = m(/SwapTotal:\s+(\d+)/);
            const sfree = m(/SwapFree:\s+(\d+)/);
            if (!tot || !av || !buf || !cac || !stot || !sfree)
                return;
            const total = parseInt(tot[1]);
            const avail = parseInt(av[1]);
            root.ramPercent = ((total - avail) / total) * 100;

            const buffers = parseInt(buf[1]);
            const cached = parseInt(cac[1]);
            const swapTotal = parseInt(stot[1]);
            const swapFree = parseInt(sfree[1]);

            root.ramTotalKb = total;
            root.ramUsedKb = total - avail;
            root.ramBuffersKb = buffers;
            root.ramCachedKb = cached;
            root.swapTotalKb = swapTotal;
            root.swapUsedKb = swapTotal - swapFree;
        }
    }

    /** @brief Connection to the global @ref Tick — fires every 500 ms. */
    property Connections _tickConn: Connections {
        target: Tick
        function onTick() {
            ramFile.reload();
            root.ramHistory = root._pushHistory(root.ramHistory, root.ramPercent);
        }
    }
}
