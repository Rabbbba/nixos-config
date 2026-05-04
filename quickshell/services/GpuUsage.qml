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

    property Timer _poller: Timer {
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            busyFile.reload();
            vramUsedFile.reload();
            vramTotalFile.reload();
        }
    }
}
