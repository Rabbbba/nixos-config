pragma Singleton
import QtQuick
import Quickshell.Io

// Polls /proc/stat and /proc/meminfo every 2 s and exposes
// cpuPercent / ramPercent for the Cpu and Ram bar modules.
//
// CPU % is computed from the delta of jiffies between two ticks
// (idle vs. total), which is the standard way to read /proc/stat.
QtObject {
    id: root

    property real cpuPercent: 0
    property real ramPercent: 0

    // Previous /proc/stat snapshot, used to compute deltas.
    property var _prev: ({
            total: 0,
            idle: 0
        })

    property FileView _cpuFile: FileView {
        id: cpuFile
        path: "/proc/stat"
        blockLoading: true

        onLoaded: {
            const line = cpuFile.text().split("\n")[0];
            const fields = line.trim().split(/\s+/).slice(1).map(Number);
            const idle = fields[3] + fields[4];
            const total = fields.reduce((a, b) => a + b, 0);

            const totalDelta = total - root._prev.total;
            const idleDelta = idle - root._prev.idle;

            if (root._prev.total > 0 && totalDelta > 0)
                root.cpuPercent = (1 - idleDelta / totalDelta) * 100;

            root._prev = {
                total: total,
                idle: idle
            };
        }
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
        }
    }

    property Timer _poller: Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuFile.reload();
            ramFile.reload();
        }
    }
}
