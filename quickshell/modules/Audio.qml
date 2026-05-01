import QtQuick
import Quickshell.Services.Pipewire

ModuleWrapper {
    id: root

    Text {
        id: audio
        property PwNode sink: Pipewire.defaultAudioSink

        color: Theme.fg1
        font.family: "Iosevka Nerd Font"
        font.pixelSize: 20

        text: {
            if (!sink || !sink.audio)
                return "󰕾  ?";
            if (sink.audio.muted)
                return "󰝟 ";
            const v = sink.audio.volume;
            if (typeof v !== "number" || isNaN(v))
                return "󰕾 ?";
            return "󰕾 " + Math.round(v * 100) + "%";
        }

        PwObjectTracker {
            objects: audio.sink ? [audio.sink] : []
        }
    }
}
