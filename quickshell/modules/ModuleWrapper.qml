import QtQuick

Item {
    id: root

    // API publique (configurable depuis l'extérieur)
    default property alias _content: inner.data
    property color bgIdle: "transparent"
    property color bgHover: "#3c3836"
    property alias hovered: ma.containsMouse

    implicitWidth: inner.childrenRect.width + 16
    implicitHeight: 30

    Rectangle {
        anchors.fill: parent
        radius: 4
        color: ma.containsMouse ? root.bgHover : root.bgIdle
        Behavior on color {
            ColorAnimation {
                duration: 150
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
