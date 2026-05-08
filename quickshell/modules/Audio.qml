import QtQuick
import Quickshell.Services.Pipewire
import "../components"
import "../popouts"
import "../services"

// Audio module: shows the default Pipewire sink's volume / mute state.
// Scroll on the module to nudge volume by ±5 %.
ModuleWrapper {
    id: root

    bgIdle: Theme.moduleBg
    bgHover: Theme.accent

    property PwNode sink: Pipewire.defaultAudioSink
    tooltip: sink ? sink.description + " · " + Math.round(sink.audio.volume * 100) + "%" : ""

    // Wheel up = louder, wheel down = quieter, clamped to [0, 1].
    onWheel: angleDelta => {
        const step = 0.05;
        const cur = sink && sink.audio ? sink.audio.volume : 0;
        if (sink && sink.audio)
            sink.audio.volume = Math.max(0, Math.min(1, cur + (angleDelta.y > 0 ? step : -step)));
    }

    StyledText {
        id: audio

        font.pixelSize: Theme.fontSizeLg
        color: root.hovered ? Theme.popupBg : Theme.text

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

        // Pipewire bindings are lazy — without a tracker, .audio.volume reads
        // as undefined. Tracking the sink keeps it live.
        PwObjectTracker {
            objects: root.sink ? [root.sink] : []
        }
    }

    ModulePopout {
        wrapper: root
        name: "audio"
        alignment: "right"
        implicitWidth: 300
        implicitHeight: 200

        AudioPopup {
            anchors.fill: parent
        }
    }

    onClicked: Visibilities.toggle("audio")
}
