  import QtQuick
  import Quickshell.Services.Pipewire

  Text {
      id: audio

      property PwNode sink: Pipewire.defaultAudioSink

      color: "#ebdbb2"
      font.pixelSize: 20

      text: {
          if (!sink || !sink.audio) return "Vol: ?"
          if (sink.audio.muted) return "Vol: MUTE"
          return "Vol: " + Math.round(sink.audio.volume * 100) + "%"
      }

      PwObjectTracker {
          objects: audio.sink ? [audio.sink] : []
      }
  }
