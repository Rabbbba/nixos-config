import QtQuick
import Quickshell                  // pour execDetached
import "../components"

Column {
    spacing: 8

    IconButton {
        icon: "󰐥 "
        iconSize: 40
        iconColor: Theme.yellow
        onClicked: Quickshell.execDetached(["systemctl", "poweroff"])
    }

    IconButton {
        icon: "󰜉 "
        iconSize: 40
        iconColor: Theme.yellow
        onClicked: Quickshell.execDetached(["systemctl", "reboot"])
    }

    IconButton {
        icon: "󰌾 "
        iconSize: 40
        iconColor: Theme.yellow
        onClicked: Quickshell.execDetached(["loginctl", "lock-session"])
    }

    IconButton {
        icon: "󰗽 "
        iconSize: 40
        iconColor: Theme.yellow
        onClicked: Quickshell.execDetached(["hyprctl", "dispatch", "exit"])
    }
}
