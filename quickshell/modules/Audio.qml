import QtQuick
import Quickshell.Services.Pipewire
import "../components"

ModuleWrapper {
    id: root

    StyledText {
        id: audio
        property PwNode sink: Pipewire.defaultAudioSink

        font.pixelSize: Theme.fontSizeLg

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
