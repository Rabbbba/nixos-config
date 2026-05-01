import QtQuick
import Quickshell.Services.Pipewire

ModuleWrapper {
    id: root

    Text {
        id: mic
        property PwNode source: Pipewire.defaultAudioSource

        color: "#ebdbb2"
        font.family: "Iosevka Nerd Font"
        font.pixelSize: 20

        text: {
            if (!source || !source.audio)
                return "󰍬 ?";
            if (source.audio.muted)
                return "󰍭";            // mic muté
            return "󰍬 " + Math.round(source.audio.volume * 100) + "%";
        }

        PwObjectTracker {
            objects: mic.source ? [mic.source] : []
        }
    }
}
