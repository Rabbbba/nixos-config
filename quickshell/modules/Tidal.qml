import QtQuick
import QtQuick.Effects
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
        implicitWidth: 520
        implicitHeight: 320
        parentItem: root
        padding: 4
        alignement: "left"
        panelWindow: root.panelWindow

        Image {
            id: bgArt
            width: parent.width
            height: parent.height
            fillMode: Image.PreserveAspectCrop
            smooth: true
            anchors.verticalCenter: parent.verticalCenter
            source: Players.tidal ? Players.tidal.trackArtUrl : ""
        }

        MultiEffect {
            source: bgArt
            anchors.fill: bgArt
            blurEnabled: true
            blur: 1.0
            saturation: -0.4
            brightness: -0.2
        }

        Row {
            anchors.centerIn: parent
            width: parent.width
            spacing: 20

            Image {
                width: 220
                height: 220
                fillMode: Image.PreserveAspectCrop
                smooth: true
                anchors.verticalCenter: parent.verticalCenter
                source: Players.tidal ? Players.tidal.trackArtUrl : ""
            }

            Column {
                width: parent.width - 240
                anchors.verticalCenter: parent.verticalCenter
                spacing: 18

                Column {
                    width: parent.width
                    spacing: 6

                    StyledText {
                        width: parent.width
                        font.bold: true
                        font.pixelSize: Theme.fontSizeLg + 6
                        text: Players.tidal ? Players.tidal.trackTitle : "—"
                    }
                    StyledText {
                        width: parent.width
                        color: Theme.fg1
                        font.pixelSize: Theme.fontSizeMd + 2
                        text: Players.tidal ? Players.tidal.trackArtist : ""
                    }
                    StyledText {
                        width: parent.width
                        color: Theme.fg4
                        font.pixelSize: Theme.fontSizeMd
                        text: Players.tidal && Players.tidal.trackAlbum ? Players.tidal.trackAlbum : ""
                    }
                }

                // Placeholder progress bar — remplacé en stage B
                Rectangle {
                    width: parent.width
                    height: 4
                    color: Theme.bg2
                    radius: 2
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10

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

                // Placeholder volume slider — remplacé en stage C
                Rectangle {
                    width: parent.width
                    height: 4
                    color: Theme.bg2
                    radius: 2
                }
            }
        }
    }

    onClicked: popup.visible = !popup.visible
}
