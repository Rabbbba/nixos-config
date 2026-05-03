pragma Singleton
import QtQuick
import Quickshell.Services.Mpris

// Singleton exposing well-known MPRIS players, kept reactive to player
// hot-plug. `Mpris.players.values.find(...)` only resolves once when bound,
// so we explicitly re-run the lookup whenever the players list changes.
QtObject {
    id: root

    property MprisPlayer tidal: null

    function _refresh() {
        const list = Mpris.players.values;
        root.tidal = list.find(p => p.identity && p.identity.toLowerCase().includes("tidal")) ?? null;
    }

    property Connections _conn: Connections {
        target: Mpris.players
        function onValuesChanged() {
            root._refresh();
        }
    }

    Component.onCompleted: _refresh()
}
