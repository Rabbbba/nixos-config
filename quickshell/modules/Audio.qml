import QtQuick
import Quickshell.Services.Pipewire
import "../components"

ModuleWrapper {
    id: root

    property PwNode sink: Pipewire.defaultAudioSink

    onWheel: angleDelta => {
        const step = 0.05;
        const cur = sink && sink.audio ? sink.audio.volume : 0;
        sink.audio.volume = Math.max(0, Math.min(1, cur + (angleDelta.y > 0 ? step : -step)));
    }

    StyledText {
        id: audio

        font.pixelSize: Theme.fontSizeLg

        text: {
            if (!root.sink || !root.sink.audio)
                return "󰕾  ?";
            if (root.sink.audio.muted)
                return "󰝟 ";
            const v = root.sink.audio.volume;
            if (typeof v !== "number" || isNaN(v))
                return "󰕾 ?";
            return "󰕾 " + Math.round(v * 100) + "%";
        }

        PwObjectTracker {
            objects: root.sink ? [root.sink] : []
        }
    }
}
