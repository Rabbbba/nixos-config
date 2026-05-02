import QtQuick
import "../services"
import "../components"

ModuleWrapper {
    id: root
    bgIdle: Theme.yellow
    bgHover: Theme.bg2

    property var panelWindow: null

    StyledText {
        text: Players.tidal ? "󰝚  " + Players.tidal.trackArtist + " - " + Players.tidal.trackTitle : ""
        color: root.hovered ? Theme.fg1 : Theme.bg1
        font.pixelSize: Theme.fontSizeMd
        font.bold: true
        width: Math.min(implicitWidth, 300)
    }

    Popout {
        id: popup
        implicitWidth: 300
        implicitHeight: 150
        parentItem: root
        panelWindow: root.panelWindow

        // contenu temporaire
        StyledText {
            anchors.centerIn: parent
            text: Players.tidal ? Players.tidal.trackTitle : "no track"
        }
    }

    onClicked: popup.visible = !popup.visible
}
