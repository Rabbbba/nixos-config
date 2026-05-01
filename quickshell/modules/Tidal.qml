import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import QtQuick.Window

ModuleWrapper {
    id: root
    bgIdle: Theme.yellow
    bgHover: Theme.bg2

    property var panelWindow: null

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
            text: root.tidal ? root.tidal.trackTitle : "no track"
        }
    }

    Component.onCompleted: console.log("window:", Window.window)

    onClicked: {
        console.log("clicked, popup.visible was =", popup.visible);
        popup.visible = !popup.visible;
        console.log("now visible:", popup.visible, "anchor:", popup.anchor.window);
    }
}
