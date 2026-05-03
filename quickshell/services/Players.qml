pragma Singleton
import QtQuick
import Quickshell.Services.Mpris

// Singleton exposing well-known MPRIS players.
//
// KNOWN BUG: this binding resolves once at startup and isn't reactive to
// Mpris.players.values mutating later — if Tidal launches after quickshell,
// `tidal` stays null. Workaround: relaunch Tidal after each quickshell restart.
// Future fix: re-bind via a Connections handler on Mpris players changes.
QtObject {
  id: root


    readonly property MprisPlayer tidal: Mpris.players.values.find(p => p.identity.toLowerCase().includes("tidal"))
}
