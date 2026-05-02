import QtQuick
import QtQuick.Effects
import "../services"
import "../components"

ModuleWrapper {
    id: root
    bgIdle: Theme.yellow
    bgHover: Theme.bg2

    property var panelWindow: null

    function fmt(s) {
        const m = Math.floor(s / 60);
        const sec = Math.floor(s % 60);
        return m + ":" + (sec < 10 ? "0" : "") + sec;
    }

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
        implicitHeight: 250
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

        Timer {
            interval: 1000
            running: popup.visible
            repeat: true
            onTriggered: {
                if (Players.tidal)
                    Players.tidal.positionChanged();
            }
        }

        Row {
            anchors.centerIn: parent
            width: parent.width
            spacing: 20

            Image {
                width: 190
                height: 190
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
                        iconSize: 40
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

                Column {
                    width: parent.width
                    spacing: 4

                    Item {
                        width: parent.width
                        height: 14

                        StyledText {
                            anchors.left: parent.left
                            color: Theme.fg4
                            text: root.fmt(Players.tidal ? Players.tidal.position : 0)
                        }
                        StyledText {
                            anchors.right: parent.right
                            color: Theme.fg4
                            text: root.fmt(Players.tidal ? Players.tidal.length : 0)
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 4
                        color: Theme.bg2
                        radius: 2

                        MouseArea {
                            anchors.fill: parent
                            anchors.topMargin: -8
                            anchors.bottomMargin: -8
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mouse => {
                                if (!Players.tidal || !Players.tidal.canSeek)
                                    return;
                                const ratio = mouse.x / width;
                                Players.tidal.position = ratio * Players.tidal.length;
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            width: parent.width * (Players.tidal && Players.tidal.length > 0 ? Players.tidal.position / Players.tidal.length : 0)
                            height: parent.height
                            color: Theme.yellow
                            radius: 2
                        }
                    }
                }
            }
        }
    }

    onClicked: popup.visible = !popup.visible
}
