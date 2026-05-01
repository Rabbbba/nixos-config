import QtQuick
import Quickshell.Io

Text {
    id: system

    property real ramPercent: 0

    color: "#ebdbb2"
    font.pixelSize: 20
    font.family: "Iosevka Nerd Font"
    text: "󰍛 " + ramPercent.toFixed(0) + "%"

    FileView {
        id: meminfo
        path: "/proc/meminfo"
        blockLoading: true

        onLoaded: {
            const content = meminfo.text();
            const total = parseInt(content.match(/MemTotal:\s+(\d+)/)[1]);
            const avail = parseInt(content.match(/MemAvailable:\s+(\d+)/)[1]);
            system.ramPercent = ((total - avail) / total) * 100;
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: meminfo.reload()
    }
}
