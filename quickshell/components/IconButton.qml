import QtQuick
import "../modules"

// Round icon button: NerdFont glyph centered, hover bg, click signal.
// Used for Power actions, Tidal transport controls, the Nix-logo button, etc.
//
// NOTE: never include a trailing space in `icon:` — the centered Text counts
// it in its width and the visible glyph drifts off-center.
Rectangle {
    id: root

    property string icon: ""
    property int iconSize: 18
    property color iconColor: Theme.text
    property int diameter: 40

    signal clicked

    width: diameter
    height: diameter
    radius: diameter / 2
    color: ma.containsMouse ? Theme.moduleBg : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: Theme.animFast
        }
    }

    StyledText {
        anchors.centerIn: parent
        text: root.icon
        color: root.iconColor
        font.pixelSize: root.iconSize
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
