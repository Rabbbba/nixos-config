import QtQuick

Item {
    id: root

    // API publique (configurable depuis l'extérieur)
    default property alias _content: inner.data
    property color bgHover: Theme.bg1
    property color bgIdle: Theme.bg2
    property alias hovered: ma.containsMouse

    implicitWidth: inner.childrenRect.width + 16
    implicitHeight: 30

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: ma.containsMouse ? root.bgHover : root.bgIdle
        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
            }
        }
    }

    Item {
        id: inner
        anchors.centerIn: parent
        width: childrenRect.width
        height: childrenRect.height
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
    }
}
