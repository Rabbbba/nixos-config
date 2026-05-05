pragma Singleton
import QtQuick
import Quickshell.Io

// Polls /sys/class/drm/cardN/device/{gpu_busy_percent, mem_info_vram_used,
// mem_info_vram_total} every 500 ms and exposes GPU utilization + VRAM
// state to the Gpu bar module and its popup.
//
// On AM5 boxes the iGPU lives on card0 (~512 M VRAM) and the dGPU on card1.
// We hardcode card1 — could be detected dynamically by picking the card
// with the largest VRAM, but that's overkill for a single-machine config.
QtObject {
    id: root

    readonly property string cardPath: "/sys/class/drm/card1/device"

    property real gpuPercent: 0
    property real vramUsed: 0    // bytes
    property real vramTotal: 0   // bytes
    property real vramPercent: 0 // 0–100

    // GPU temperatures in °C: edge (die border), junction (hottest spot),
    // mem (VRAM). The hwmon directory is resolved at startup — only one
    // hwmon* lives under cardPath/hwmon/ for the dGPU.
    property real gpuTempEdge: 0
    property real gpuTempJunction: 0
    property real gpuTempMem: 0
    property string _gpuHwmon: ""

    // Rolling history of the last `_historyLength` GPU% samples, one per
    // 500 ms tick. Sparkline component reads this directly.
    readonly property int _historyLength: 60
    property var gpuHistory: []

    function _pushHistory(arr, value) {
        const next = arr.slice();
        next.push(value);
        if (next.length > root._historyLength)
            next.shift();
        return next;
    }

    property FileView _busyFile: FileView {
        id: busyFile
        path: root.cardPath + "/gpu_busy_percent"
        blockLoading: true
        onLoaded: root.gpuPercent = parseInt(busyFile.text().trim())
    }

    property FileView _vramUsedFile: FileView {
        id: vramUsedFile
        path: root.cardPath + "/mem_info_vram_used"
        blockLoading: true
        onLoaded: {
            root.vramUsed = parseInt(vramUsedFile.text().trim());
            if (root.vramTotal > 0)
                root.vramPercent = (root.vramUsed / root.vramTotal) * 100;
        }
    }

    property FileView _vramTotalFile: FileView {
        id: vramTotalFile
        path: root.cardPath + "/mem_info_vram_total"
        blockLoading: true
        onLoaded: root.vramTotal = parseInt(vramTotalFile.text().trim())
    }

    // One-shot resolver: cardPath/hwmon/ contains a single hwmonN dir for
    // the dGPU. Stdout is the resolved path; we then bind the temp FileViews.
    property Process _resolveGpuHwmon: Process {
        command: ["sh", "-c", "ls -d " + root.cardPath + "/hwmon/hwmon* 2>/dev/null | head -1"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (data)
                    root._gpuHwmon = data.trim();
            }
        }
    }

    property FileView _tempEdgeFile: FileView {
        id: tempEdgeFile
        path: root._gpuHwmon ? root._gpuHwmon + "/temp1_input" : ""
        blockLoading: true
        onLoaded: {
            if (root._gpuHwmon)
                root.gpuTempEdge = parseInt(tempEdgeFile.text().trim()) / 1000;
        }
    }

    property FileView _tempJunctionFile: FileView {
        id: tempJunctionFile
        path: root._gpuHwmon ? root._gpuHwmon + "/temp2_input" : ""
        blockLoading: true
        onLoaded: {
            if (root._gpuHwmon)
                root.gpuTempJunction = parseInt(tempJunctionFile.text().trim()) / 1000;
        }
    }

    property FileView _tempMemFile: FileView {
        id: tempMemFile
        path: root._gpuHwmon ? root._gpuHwmon + "/temp3_input" : ""
        blockLoading: true
        onLoaded: {
            if (root._gpuHwmon)
                root.gpuTempMem = parseInt(tempMemFile.text().trim()) / 1000;
        }
    }

    property Timer _poller: Timer {
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            busyFile.reload();
            vramUsedFile.reload();
            vramTotalFile.reload();
            if (root._gpuHwmon) {
                tempEdgeFile.reload();
                tempJunctionFile.reload();
                tempMemFile.reload();
            }
            root.gpuHistory = root._pushHistory(root.gpuHistory, root.gpuPercent);
        }
    }
}
