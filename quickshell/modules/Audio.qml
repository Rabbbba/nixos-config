import QtQuick
import Quickshell.Services.Pipewire

Item {
    id: root
    implicitWidth: audio.implicitWidth + 16
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
        id: audio
        anchors.centerIn: parent

        property PwNode sink: Pipewire.defaultAudioSink

        color: "#ebdbb2"
        font.family: "Iosevka Nerd Font"
        font.pixelSize: 20

        text: {
            if (!sink || !sink.audio)
                return "󰕾  ?";
            if (sink.audio.muted)
                return "󰝟 ";
            return "󰕾 " + Math.round(sink.audio.volume * 100) + "%";
        }

        PwObjectTracker {
            objects: audio.sink ? [audio.sink] : []
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
    }
}
