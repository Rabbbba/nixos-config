import QtQuick
import QtQuick.Effects
import Quickshell.Io
import "../services"
import "../components"

// Tidal "now playing" pill in the bar + a rich popout on click.
// Popout shows: blurred album-art background, cover, title/artist/album,
// transport buttons (shuffle, prev, play/pause, next, loop), volume slider,
// and a 24-band cava equalizer that doubles as a seek bar.
ModuleWrapper {
    id: root
    bgIdle: Theme.accent
    bgHover: Theme.moduleBg

    property var panelWindow: null

    // Format seconds as "m:ss" — for elapsed/total track times.
    function fmt(s) {
        const m = Math.floor(s / 60);
        const sec = Math.floor(s % 60);
        return m + ":" + (sec < 10 ? "0" : "") + sec;
    }

    StyledText {
        text: Players.tidal ? "󰝚  " + Players.tidal.trackArtist + " - " + Players.tidal.trackTitle : ""
        color: root.hovered ? Theme.text : Theme.popupBg
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
        visible: Visibilities.current === "tidal"

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

        // MPRIS doesn't push position changes — poke the change signal
        // ourselves once a second so the seek bar / time labels update.
        Timer {
            interval: 1000
            running: popup.visible
            repeat: true
            onTriggered: {
                if (Players.tidal)
                    Players.tidal.positionChanged();
            }
        }

        // cava streams 24 ASCII bar heights per frame on stdout.
        Process {
            id: cavaProc
            command: ["cava", "-p", "/etc/nixos/cava/config"]
            running: popup.visible

            stdout: SplitParser {
                splitMarker: "\n"
                onRead: data => {
                    if (!data)
                        return;
                    const nums = data.split(";").filter(s => s.length > 0).map(s => parseInt(s, 10));
                    if (nums.length === 24)
                        progressBars.values = nums;
                }
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
                        color: Theme.text
                        font.pixelSize: Theme.fontSizeMd + 2
                        text: Players.tidal ? Players.tidal.trackArtist : ""
                    }
                    StyledText {
                        width: parent.width
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontSizeMd
                        text: Players.tidal && Players.tidal.trackAlbum ? Players.tidal.trackAlbum : ""
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10

                    IconButton {
                        icon: "󰒝"
                        iconColor: Players.tidal && Players.tidal.shuffle ? Theme.accent : Theme.textMuted
                        onClicked: if (Players.tidal)
                            Players.tidal.shuffle = !Players.tidal.shuffle
                    }

                    IconButton {
                        icon: "󰒮"
                        onClicked: if (Players.tidal)
                            Players.tidal.previous()
                    }

                    IconButton {
                        icon: Players.tidal && Players.tidal.isPlaying ? "󰏤" : "󰐊"
                        iconSize: 40
                        iconColor: Theme.accent
                        diameter: 48
                        onClicked: if (Players.tidal)
                            Players.tidal.togglePlaying()
                    }

                    IconButton {
                        icon: "󰒭"
                        onClicked: if (Players.tidal)
                            Players.tidal.next()
                    }

                    // MPRIS loop state: 0 = None, 1 = Track, 2 = Playlist.
                    IconButton {
                        icon: {
                            if (!Players.tidal)
                                return "󰑗";
                            const s = Players.tidal.loopState;
                            if (s === 1)
                                return "󰑘";
                            if (s === 2)
                                return "󰑖";
                            return "󰑗";
                        }
                        iconColor: Players.tidal && Players.tidal.loopState !== 0 ? Theme.accent : Theme.textMuted
                        onClicked: if (Players.tidal)
                            Players.tidal.loopState = (Players.tidal.loopState + 1) % 3
                    }
                }

                Row {
                    width: parent.width
                    spacing: 8

                    StyledText {
                        id: volIcon
                        anchors.verticalCenter: parent.verticalCenter
                        text: Players.tidal && Players.tidal.volume === 0 ? "󰝟" : "󰕾"
                        color: Theme.textMuted
                        property real previousVolume: 1.0

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!Players.tidal)
                                    return;
                                if (Players.tidal.volume > 0) {
                                    volIcon.previousVolume = Players.tidal.volume;
                                    Players.tidal.volume = 0;
                                } else {
                                    Players.tidal.volume = volIcon.previousVolume > 0 ? volIcon.previousVolume : 1.0;
                                }
                            }
                        }
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 28
                        height: 4
                        color: Theme.moduleBg
                        radius: 2

                        MouseArea {
                            anchors.fill: parent
                            anchors.topMargin: -8
                            anchors.bottomMargin: -8
                            cursorShape: Qt.PointingHandCursor

                            function setVolume(x) {
                                if (!Players.tidal)
                                    return;
                                const ratio = Math.max(0, Math.min(1, x / width));
                                Players.tidal.volume = ratio;
                            }

                            onPressed: mouse => setVolume(mouse.x)
                            onPositionChanged: mouse => {
                                if (pressed)
                                    setVolume(mouse.x);
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            width: parent.width * (Players.tidal ? Players.tidal.volume : 0)
                            height: parent.height
                            color: Theme.accent
                            radius: 2
                        }
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
                            color: Theme.textMuted
                            text: root.fmt(Players.tidal ? Players.tidal.position : 0)
                        }
                        StyledText {
                            anchors.right: parent.right
                            color: Theme.textMuted
                            text: root.fmt(Players.tidal ? Players.tidal.length : 0)
                        }
                    }

                    // Bars react to audio (cava), coloured by playback position.
                    Item {
                        id: progressBars
                        width: parent.width
                        height: 28

                        property var values: new Array(24).fill(0)
                        readonly property real progress: Players.tidal && Players.tidal.length > 0 ? Players.tidal.position / Players.tidal.length : 0

                        Repeater {
                            model: 24
                            Rectangle {
                                width: (progressBars.width - 23 * 2) / 24
                                x: index * (width + 2)
                                anchors.bottom: parent.bottom
                                height: Math.max(4, (progressBars.values[index] / 100) * progressBars.height)
                                color: (index + 0.5) / 24 < progressBars.progress ? Theme.accent : Theme.border
                                radius: 1
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            function seek(x) {
                                if (!Players.tidal || !Players.tidal.canSeek)
                                    return;
                                const ratio = Math.max(0, Math.min(1, x / width));
                                Players.tidal.position = ratio * Players.tidal.length;
                            }

                            onPressed: mouse => seek(mouse.x)
                            onPositionChanged: mouse => {
                                if (pressed)
                                    seek(mouse.x);
                            }
                        }
                    }
                }
            }
        }
    }

    onClicked: Visibilities.toggle("tidal")
}
