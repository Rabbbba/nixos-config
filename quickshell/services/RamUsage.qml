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
            const total = parseInt(content.match(/MemTotal:\s+(\d+)/)[1]);
            const avail = parseInt(content.match(/MemAvailable:\s+(\d+)/)[1]);
            root.ramPercent = ((total - avail) / total) * 100;

            const buffers = parseInt(content.match(/Buffers:\s+(\d+)/)[1]);
            const cached = parseInt(content.match(/Cached:\s+(\d+)/)[1]);
            const swapTotal = parseInt(content.match(/SwapTotal:\s+(\d+)/)[1]);
            const swapFree = parseInt(content.match(/SwapFree:\s+(\d+)/)[1]);

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
