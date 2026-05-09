pragma Singleton
import QtQuick
import Quickshell.Services.Mpris

/**
 * @brief Singleton exposing well-known MPRIS players (Tidal in particular).
 *
 * Stays reactive to player hot-plug: `Mpris.players.values.find(...)` only
 * resolves once when bound, so we re-run the lookup whenever the players
 * list changes.
 *
 * Tidal Hi-Fi resets its internal volume on every track change — we work
 * around it by remembering the last user-set value and re-applying it
 * shortly after each track switch.
 */
QtObject {
    id: root

    /** Reference to the Tidal MPRIS player, or null if Tidal is not running. */
    property MprisPlayer tidal: null

    // Last volume explicitly set by the user (-1 = never set yet).
    property real _savedTidalVolume: -1

    function _refresh() {
        const list = Mpris.players.values;
        root.tidal = list.find(p => p.identity && p.identity.toLowerCase().includes("tidal")) ?? null;
    }

    /**
     * Public setter: saves the value AND applies it to the player.
     * Use this from the UI instead of writing `tidal.volume` directly,
     * to benefit from auto-restore after track changes.
     * @param v Target volume (0.0 to 1.0).
     */
    function setTidalVolume(v: real): void {
        root._savedTidalVolume = v;
        if (root.tidal)
            root.tidal.volume = v;
    }

    property Connections _conn: Connections {
        target: Mpris.players
        function onValuesChanged() {
            root._refresh();
        }
    }

    // When the track changes, Tidal resets the volume. The reset arrives
    // slightly AFTER trackTitleChanged, so we restore via a short Timer
    // (100 ms) to overwrite the reset rather than be overwritten by it.
    property Connections _trackConn: Connections {
        target: root.tidal
        function onTrackTitleChanged() {
            if (root._savedTidalVolume >= 0)
                root._restoreTimer.restart();
        }
    }

    property Timer _restoreTimer: Timer {
        interval: 100
        repeat: false
        onTriggered: {
            if (root.tidal && root._savedTidalVolume >= 0)
                root.tidal.volume = root._savedTidalVolume;
        }
    }

    Component.onCompleted: _refresh()
}
