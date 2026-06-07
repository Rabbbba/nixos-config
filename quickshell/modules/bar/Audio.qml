// qmllint disable missing-property
import QtQuick
import Quickshell.Services.Pipewire
import "../../components"
import "../../services"

/**
 * @brief Audio module: shows the default Pipewire sink's volume and mute state.
 *
 * Scrolling on the module nudges the sink volume by ±5 %, clamped to [0, 1].
 * Clicking toggles the @ref popouts::AudioPopup via @c Visibilities.
 */
ModuleWrapper {
    id: root

    bgIdle: Theme.color.moduleBg
    bgHover: Theme.color.accent

    /** Currently default Pipewire audio sink. */
    property PwNode sink: Pipewire.defaultAudioSink
    tooltip: sink ? sink.description + " · " + Math.round(sink.audio.volume * 100) + "%" : ""

    // Wheel up = louder, wheel down = quieter, clamped to [0, 1].
    onWheel: angleDelta => {
        const step = 0.05;
        const cur = sink && sink.audio ? sink.audio.volume : 0;
        if (sink && sink.audio)
            sink.audio.volume = Math.max(0, Math.min(1, cur + (angleDelta.y > 0 ? step : -step)));
    }

    // Worst-case slot width (icon + "100%") — keeps the module width stable.
    TextMetrics {
        id: audioMetrics
        font.family: Theme.font.family
        font.pixelSize: Theme.font.sizeLg
        text: audio.text.split(" ")[0] + " 100%"
    }

    StyledText {
        id: audio

        font.pixelSize: Theme.font.sizeLg
        color: root.hovered ? Theme.color.popupBg : Theme.color.text
        width: audioMetrics.width
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideNone

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

    onClicked: Visibilities.toggle("audio")
}
