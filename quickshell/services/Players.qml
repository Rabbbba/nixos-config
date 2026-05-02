pragma Singleton
import QtQuick
import Quickshell.Services.Mpris

QtObject {
  id: root


    readonly property MprisPlayer tidal: Mpris.players.values.find(p => p.identity.toLowerCase().includes("tidal"))
}
