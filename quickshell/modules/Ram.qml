import QtQuick
import Quickshell.Io

Item {
    id: root
    implicitWidth: ram.implicitWidth + 16
    height: 30

    Rectangle {
        anchors.fill: parent
        radius: 4
        color: ma.containsMouse ? "#3c3836" : "transparent"
        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    Text {
        id: ram

        anchors.centerIn: parent

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
                ram.ramPercent = ((total - avail) / total) * 100;
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

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
    }
}
