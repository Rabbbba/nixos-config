import QtQuick

ModuleWrapper {
    id: root
    bgIdle: Theme.yellow
    bgHover: Theme.bg2

    Text {
        property date now: new Date()
        color: root.hovered ? Theme.fg1 : Theme.bg1
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
