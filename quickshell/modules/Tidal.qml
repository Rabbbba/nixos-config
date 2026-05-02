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
        panelWindow: root.panelWindow

        Column {
            anchors.centerIn: parent
            width: parent.width
            spacing: 14

            Row {
                spacing: 12
                width: parent.width

                Image {
                    width: 72
                    height: 72
                    fillMode: Image.PreserveAspectFit
                    source: Players.tidal ? Players.tidal.trackArtUrl : ""
                }

                Column {
                    spacing: 4
                    width: parent.width - 84

                    StyledText {
                        width: parent.width
                        font.bold: true
                        text: Players.tidal ? Players.tidal.trackTitle : "—"
                    }
                    StyledText {
                        width: parent.width
                        color: Theme.fg4
                        text: Players.tidal ? Players.tidal.trackArtist : ""
                    }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 28

                StyledText {
                    text: "󰒮"
                    font.pixelSize: 22
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (Players.tidal) Players.tidal.previous()
                    }
                }

                StyledText {
                    text: Players.tidal && Players.tidal.isPlaying ? "󰏤" : "󰐊"
                    font.pixelSize: 26
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (Players.tidal) Players.tidal.togglePlaying()
                    }
                }

                StyledText {
                    text: "󰒭"
                    font.pixelSize: 22
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (Players.tidal) Players.tidal.next()
                    }
                }
            }
        }
    }

    onClicked: popup.visible = !popup.visible
}
