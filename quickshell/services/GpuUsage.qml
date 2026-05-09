pragma Singleton
import QtQuick
import Quickshell.Io

/**
 * @brief Singleton exposing GPU utilization, VRAM state, and temperatures.
 *
 * Polls `/sys/class/drm/cardN/device/{gpu_busy_percent, mem_info_vram_used,
 * mem_info_vram_total}` every 500 ms.
 *
 * On AM5 boxes the iGPU lives on card0 (~512 M VRAM) and the dGPU on card1.
 * We hardcode card1 — dynamic detection (largest VRAM) is possible but
 * overkill for a single-machine config.
 *
 * The hwmon directory is resolved at startup since only one `hwmon*` lives
 * under `cardPath/hwmon/` for the dGPU.
 */
QtObject {
    id: root

    /** sysfs path to the GPU device (card0 = iGPU, card1 = dGPU on AM5). */
    readonly property string cardPath: "/sys/class/drm/card1/device"

    /** GPU utilization as a percentage (0–100). */
    property real gpuPercent: 0
    /** Used VRAM in bytes. */
    property real vramUsed: 0
    /** Total VRAM in bytes. */
    property real vramTotal: 0
    /** Used VRAM as a percentage (0–100). */
    property real vramPercent: 0

    /** Edge (die border) temperature in degC. */
    property real gpuTempEdge: 0
    /** Junction (hottest spot) temperature in degC. */
    property real gpuTempJunction: 0
    /** VRAM memory temperature in degC. */
    property real gpuTempMem: 0
    property string _gpuHwmon: ""

    readonly property int _historyLength: 60
    /**
     * Rolling history of the last 60 @ref gpuPercent samples (one per
     * 500 ms tick). Read directly by the Sparkline component.
     */
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
    // the dGPU. stdout is the resolved path; we then bind the temp FileViews.
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
