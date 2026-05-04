import QtQuick
import "../services"
import "../components"
import "../popouts"

// Tidal "now playing" pill in the bar — clicking opens a rich popup
// (TidalPopup) with album art, transport controls, volume, and equalizer.
ModuleWrapper {
    id: root
    bgIdle: Theme.accent
    bgHover: Theme.moduleBg

    StyledText {
        text: Players.tidal ? "󰝚  " + Players.tidal.trackArtist + " - " + Players.tidal.trackTitle : ""
        color: root.hovered ? Theme.text : Theme.popupBg
        font.pixelSize: Theme.fontSizeMd
        font.bold: true
        width: Math.min(implicitWidth, 300)
    }

    ModulePopout {
        id: popup
        wrapper: root
        name: "tidal"
        implicitWidth: 520
        implicitHeight: 250
        padding: 4
        alignement: "left"

        TidalPopup {
            anchors.fill: parent
            popupVisible: popup.visible
        }
    }

    onClicked: Visibilities.toggle("tidal")
}
