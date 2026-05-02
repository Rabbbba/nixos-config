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
        implicitWidth: 340
        implicitHeight: 190
        parentItem: root
        alignement: "left"
        panelWindow: root.panelWindow
        Column {
            anchors.centerIn: parent
            width: parent.width
            spacing: 16

            Row {
                spacing: 16
                width: parent.width

                Image {
                    width: 80
                    height: 80
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    source: Players.tidal ? Players.tidal.trackArtUrl : ""
                }

                Column {
                    spacing: 6
                    width: parent.width - 96
                    anchors.verticalCenter: parent.verticalCenter

                    StyledText {
                        width: parent.width
                        font.bold: true
                        font.pixelSize: Theme.fontSizeMd + 2
                        text: Players.tidal ? Players.tidal.trackTitle : "—"
                    }
                    StyledText {
                        width: parent.width
                        color: Theme.fg4
                        font.pixelSize: Theme.fontSizeMd
                        text: Players.tidal ? Players.tidal.trackArtist : ""
                    }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                IconButton {
                    icon: "󰒮"
                    onClicked: if (Players.tidal)
                        Players.tidal.previous()
                }

                IconButton {
                    icon: Players.tidal && Players.tidal.isPlaying ? "󰏤" : "󰐊"
                    iconSize: 22
                    iconColor: Theme.yellow
                    diameter: 48
                    onClicked: if (Players.tidal)
                        Players.tidal.togglePlaying()
                }

                IconButton {
                    icon: "󰒭"
                    onClicked: if (Players.tidal)
                        Players.tidal.next()
                }
            }
        }
    }

    onClicked: popup.visible = !popup.visible
}
