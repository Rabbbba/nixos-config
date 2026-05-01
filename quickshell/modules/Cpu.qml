import QtQuick
import Quickshell.Io

ModuleWrapper {
    id: root

    Text {
        id: cpu
        property real cpuPercent: 0
        property var prev: ({
                total: 0,
                idle: 0
            })

        color: "#ebdbb2"
        font.pixelSize: 20
        font.family: "Iosevka Nerd Font"
        text: "󰘚 " + cpuPercent.toFixed(0) + "%"

        FileView {
            id: cpuinfo
            path: "/proc/stat"
            blockLoading: true

            onLoaded: {
                const line = cpuinfo.text().split("\n")[0];                     // 1ère ligne "cpu ..."
                const fields = line.trim().split(/\s+/).slice(1).map(Number);   // skip "cpu", convertir
                const idle = fields[3] + fields[4];                            // idle + iowait
                const total = fields.reduce((a, b) => a + b, 0);                // somme

                // delta vs précédent
                const totalDelta = total - cpu.prev.total;
                const idleDelta = idle - cpu.prev.idle;

                if (cpu.prev.total > 0 && totalDelta > 0) {
                    cpu.cpuPercent = (1 - idleDelta / totalDelta) * 100;
                }

                cpu.prev = {
                    total: total,
                    idle: idle
                };
            }
        }

        Timer {
            interval: 2000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: cpuinfo.reload()
        }
    }
}
