import QtQuick

Text {
    id: clock

    property date now: new Date()

    color: "#ebdbb2"
    font.family: "Iosevka Nerd Font"
    font.pixelSize: 20
    text: Qt.formatDateTime(now, "HH:mm:ss")

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clock.now = new Date()
    }
}
