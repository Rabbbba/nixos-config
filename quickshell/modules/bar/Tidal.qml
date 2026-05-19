import QtQuick
import "../../services"
import "../../components"

/**
 * @brief "Now playing" pill for Tidal — toggles the popout on click.
 *
 * Shows `<artist> - <title>` from the @ref services::Players singleton.
 * Clicking toggles the Tidal popout via @c Visibilities.
 */
ModuleWrapper {
    id: root
    bgIdle: Theme.color.accent
    bgHover: Theme.color.moduleBg

    StyledText {
        text: Players.tidal ? "󰝚  " + Players.tidal.trackArtist + " - " + Players.tidal.trackTitle : ""
        color: root.hovered ? Theme.color.text : Theme.color.popupBg
        font.pixelSize: Theme.font.sizeMd
        font.bold: true
        width: Math.min(implicitWidth, 300)
    }

    onClicked: Visibilities.toggle("tidal")
}
