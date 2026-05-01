import QtQuick

ModuleWrapper {
    id: root
    bgIdle: "#fabd2f"
    bgHover: "#3c3836"

    Text {
        property date now: new Date()
        color: root.hovered ? "#ebdbb2" : "#3c3836"
        font.family: "Iosevka Nerd Font"
        font.pixelSize: 20
        font.bold: true
        text: Qt.formatDateTime(now, "HH:mm dd/MM")
        Timer {
            interval: 60000
            running: true
            repeat: true
            onTriggered: parent.now = new Date()
        }
    }
}
