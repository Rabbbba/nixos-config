import QtQuick
import "../modules"

Rectangle {
    id: root

    property string icon: ""
    property int iconSize: 18
    property color iconColor: Theme.fg1
    property int diameter: 40

    signal clicked

    width: diameter
    height: diameter
    radius: diameter / 2
    color: ma.containsMouse ? Theme.bg2 : "transparent"

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
