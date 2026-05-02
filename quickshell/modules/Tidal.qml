import QtQuick
import Quickshell
import QtQuick.Window
import "../services"

ModuleWrapper {
    id: root
    bgIdle: Theme.yellow
    bgHover: Theme.bg2

    property var panelWindow: null


    Text {
        text: Players.tidal ? "󰝚  " + Players.tidal.trackArtist + " - " + Players.tidal.trackTitle : ""
        color: root.hovered ? Theme.fg1 : Theme.bg1
        font.family: "Iosevka Nerd Font"
        font.pixelSize: 18
        font.bold: true
        elide: Text.ElideRight
        width: Math.min(implicitWidth, 300)
    }

    PopupWindow {
        id: popup
        visible: false
        implicitWidth: 300
        implicitHeight: 150
        color: Theme.bg1

        anchor.window: root.panelWindow          // ← le PanelWindow parent
        anchor.rect.x: root.panelWindow.width / 2 - popup.width / 2
        anchor.rect.y: root.panelWindow.height

        // contenu temporaire
        Text {
            anchors.centerIn: parent
            color: Theme.fg1
            text: Players.tidal ? Players.tidal.trackTitle : "no track"
        }
    }

    onClicked: popup.visible = !popup.visible
}
