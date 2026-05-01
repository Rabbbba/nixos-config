import QtQuick
import Quickshell.Services.Mpris

ModuleWrapper {
    id: root
    bgIdle: Theme.yellow
    bgHover: Theme.bg2

    property var tidal: Mpris.players.values.find(p => p.identity.toLowerCase().includes("tidal"))

    Text {
        text: root.tidal ? "󰝚  " + root.tidal.trackArtist + " - " + root.tidal.trackTitle : ""
        color: root.hovered ? Theme.fg1 : Theme.bg1
        font.family: "Iosevka Nerd Font"
        font.pixelSize: 18
        font.bold: true
        elide: Text.ElideRight
        width: Math.min(implicitWidth, 300)
    }
}
