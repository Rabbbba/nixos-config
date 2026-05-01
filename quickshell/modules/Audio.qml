import QtQuick
import Quickshell.Services.Pipewire

Text {
    id: audio

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
