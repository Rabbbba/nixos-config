pragma Singleton
import QtQuick
import Quickshell.Io

// Polls /proc/meminfo every 500 ms and exposes RAM (used / total / buffers
// / cached) and swap state to the Ram bar module and its popup.
QtObject {
    id: root

    property real ramPercent: 0
    property real ramUsedKb: 0
    property real ramTotalKb: 0
    property real ramBuffersKb: 0
    property real ramCachedKb: 0
    property real swapUsedKb: 0
    property real swapTotalKb: 0

    // Rolling history of the last `_historyLength` samples, one entry per
    // 500 ms tick. Sparkline reads ramHistory directly.
    readonly property int _historyLength: 60
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

    property Timer _poller: Timer {
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            ramFile.reload();
            root.ramHistory = root._pushHistory(root.ramHistory, root.ramPercent);
        }
    }
}
