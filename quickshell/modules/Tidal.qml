import QtQuick
import "../services"
import "../components"
import "../popouts"

/**
 * @brief "Now playing" pill for Tidal — opens a rich popup on click.
 *
 * Shows `<artist> - <title>` from the @ref services::Players singleton.
 * Clicking opens @ref popouts::TidalPopup (album art, transport controls,
 * volume slider, cava equalizer doubling as a seek bar).
 */
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
        implicitHeight: 270
        padding: 4
        alignment: "left"

        TidalPopup {
            anchors.fill: parent
            popupVisible: popup.visible
        }
    }

    onClicked: Visibilities.toggle("tidal")
}
