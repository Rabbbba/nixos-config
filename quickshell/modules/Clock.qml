import QtQuick

Item {
    id: root
    implicitWidth: clock.implicitWidth + 16
    height: 30

    Rectangle {
        anchors.fill: parent
        radius: 4
        color: ma.containsMouse ? "#3c3836" : "#fabd2f"
        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }
    Text {
        id: clock

        property date now: new Date()
        anchors.centerIn: parent
        color: ma.containsMouse ? "#ebdbb2" : "#3c3836"
        font.family: "Iosevka Nerd Font"
        font.pixelSize: 20
        font.bold: true
        text: Qt.formatDateTime(now, "HH:mm:ss")

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clock.now = new Date()
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
    }
}
