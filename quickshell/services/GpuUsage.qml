pragma Singleton
import QtQuick
import Quickshell.Io
import NativeSensors
import "."

/**
 * @brief Singleton exposing GPU utilization, VRAM state, and temperatures.
 *
 * Polls `/sys/class/drm/cardN/device/{gpu_busy_percent, mem_info_vram_used,
 * mem_info_vram_total}` every 500 ms for utilization and VRAM.
 *
 * On AM5 boxes the iGPU lives on card0 (~512 M VRAM) and the dGPU on card1.
 * We hardcode card1 — dynamic detection (largest VRAM) is possible but
 * overkill for a single-machine config.
 *
 * Temperatures (edge/junction/mem) are delegated to the native `NativeHwmon`
 * plugin, each scoped to `cardPath/hwmon` so it resolves the dGPU chip rather
 * than the iGPU (both report as "amdgpu") and reads temp1/temp2/temp3_input.
 */
QtObject {
    id: root

    property NativeHwmon _edge: NativeHwmon {
        tempIndex: 1
        sensorName: "amdgpu"
        hwmonRoot: root.cardPath + "/hwmon"
    }

    property NativeHwmon _junction: NativeHwmon {
        tempIndex: 2
        sensorName: "amdgpu"
        hwmonRoot: root.cardPath + "/hwmon"
    }

    property NativeHwmon _mem: NativeHwmon {
        tempIndex: 3
        sensorName: "amdgpu"
        hwmonRoot: root.cardPath + "/hwmon"
    }

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
    readonly property real gpuTempEdge: _edge.temperature
    /** Junction (hottest spot) temperature in degC. */
    readonly property real gpuTempJunction: _junction.temperature
    /** VRAM memory temperature in degC. */
    readonly property real gpuTempMem: _mem.temperature

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

    /** @brief Connection to the global @ref Tick — fires every 500 ms. */
    property Connections _tickConn: Connections {
        target: Tick
        function onTick() {
            busyFile.reload();
            vramUsedFile.reload();
            vramTotalFile.reload();
            root.gpuHistory = root._pushHistory(root.gpuHistory, root.gpuPercent);
        }
    }
}
