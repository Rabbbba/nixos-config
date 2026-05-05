pragma Singleton
import QtQuick
import Quickshell.Io

// Polls /proc/stat, /proc/meminfo, and /proc/loadavg every 500 ms and
// exposes CPU (global + per-core), RAM, swap, and load-average state to
// the Cpu and Ram bar modules and their popups.
//
// CPU % is computed from the delta of jiffies between two ticks
// (idle vs. total), which is the standard way to read /proc/stat.
QtObject {
    id: root

    property real cpuPercent: 0
    property var cpuCoresPercent: []
    property var _prevCores: []

    property real ramPercent: 0
    property real ramUsedKb: 0
    property real ramTotalKb: 0
    property real ramBuffersKb: 0
    property real ramCachedKb: 0
    property real swapUsedKb: 0
    property real swapTotalKb: 0

    // Rolling history of the last `_historyLength` samples, one entry per
    // 500 ms tick. Sparkline component reads these directly.
    readonly property int _historyLength: 60
    property var cpuHistory: []
    property var ramHistory: []

    function _pushHistory(arr, value) {
        const next = arr.slice();
        next.push(value);
        if (next.length > root._historyLength)
            next.shift();
        return next;
    }

    property var loadAverage: ({
            l1: 0,
            l5: 0,
            l15: 0
        })

    // CPU temperature (Tctl) in °C. The hwmon path is resolved at startup
    // because hwmon numbering isn't stable across reboots — we scan
    // /sys/class/hwmon/*/name for "k10temp".
    property real cpuTemp: 0
    property string _cpuHwmon: ""

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

            const coreLines = cpuFile.text().split("\n").filter(l => /^cpu\d+\s/.test(l));

            const coresPercent = [];
            const newPrevCores = [];

            coreLines.forEach((coreLine, i) => {
                const coreFields = coreLine.trim().split(/\s+/).slice(1).map(Number);
                const coreIdle = coreFields[3] + coreFields[4];
                const coreTotal = coreFields.reduce((a, b) => a + b, 0);
                const prev = root._prevCores[i] || {
                    idle: 0,
                    total: 0
                };
                const coreTotalDelta = coreTotal - prev.total;
                const coreIdleDelta = coreIdle - prev.idle;
                let percent = 0;
                if (prev.total > 0 && coreTotalDelta > 0)
                    percent = (1 - coreIdleDelta / coreTotalDelta) * 100;
                coresPercent.push(percent);
                newPrevCores.push({
                    idle: coreIdle,
                    total: coreTotal
                });
            });
            root.cpuCoresPercent = coresPercent;
            root._prevCores = newPrevCores;
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

    property FileView _loadFile: FileView {
        id: loadFile
        path: "/proc/loadavg"
        blockLoading: true

        onLoaded: {
            const content = loadFile.text();
            const fields = content.trim().split(/\s+/);
            const l1 = parseFloat(fields[0]);
            const l5 = parseFloat(fields[1]);
            const l15 = parseFloat(fields[2]);
            root.loadAverage = {
                l1,
                l5,
                l15
            };
        }
    }

    // One-shot resolver: walks /sys/class/hwmon to find the k10temp chip.
    // Stdout is the resolved hwmonN directory; we then bind cpuTempFile.path.
    property Process _resolveCpuHwmon: Process {
        command: ["sh", "-c", "for f in /sys/class/hwmon/*/name; do [ \"$(cat \"$f\")\" = \"k10temp\" ] && dirname \"$f\" && break; done"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (data)
                    root._cpuHwmon = data.trim();
            }
        }
    }

    property FileView _cpuTempFile: FileView {
        id: cpuTempFile
        path: root._cpuHwmon ? root._cpuHwmon + "/temp1_input" : ""
        blockLoading: true
        onLoaded: {
            if (root._cpuHwmon)
                root.cpuTemp = parseInt(cpuTempFile.text().trim()) / 1000;
        }
    }

    property Timer _poller: Timer {
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuFile.reload();
            ramFile.reload();
            loadFile.reload();
            if (root._cpuHwmon)
                cpuTempFile.reload();
            root.cpuHistory = root._pushHistory(root.cpuHistory, root.cpuPercent);
            root.ramHistory = root._pushHistory(root.ramHistory, root.ramPercent);
        }
    }
}
