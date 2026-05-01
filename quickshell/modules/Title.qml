import QtQuick
import Quickshell.Io

Item {
    id: root
    implicitWidth: title.implicitWidth + 16
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
        id: title
        anchors.centerIn: parent
        property string monitor: ""    // passé depuis shell.qml comme pour Tags
        property string current: ""    // le titre courant

        color: "#ebdbb2"
        font.family: "Iosevka Nerd Font"
        font.pixelSize: 18              // un peu plus petit que les modules
        text: current
        elide: Text.ElideRight          // tronque avec "..." si trop long
        width: 400                      // largeur max — sans ça, elide ne fait rien
        horizontalAlignment: Text.AlignLeft

        Process {
            command: ["mmsg", "-w"]
            running: true

            stdout: SplitParser {
                splitMarker: "\n"
                onRead: data => {
                    const parts = data.split(" ");
                    if (parts[0] !== title.monitor)
                        return;
                    if (parts[1] !== "title")
                        return;
                    title.current = parts.slice(2).join(" ");
                }
            }
        }
    }
    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
    }
}
