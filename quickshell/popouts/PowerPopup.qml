import QtQuick
import Quickshell                  // for execDetached
import "../modules"
import "../components"

// Vertical stack of 4 power actions, lives inside the Nix-logo button's Popout.
// Glyphs (in order): poweroff, reboot, lock, logout.
Column {
    spacing: 8

    IconButton {
        icon: "󰐥"
        iconSize: 40
        iconColor: Theme.accent
        onClicked: Quickshell.execDetached(["systemctl", "poweroff"])
    }

    IconButton {
        icon: "󰜉"
        iconSize: 40
        iconColor: Theme.accent
        onClicked: Quickshell.execDetached(["systemctl", "reboot"])
    }

    IconButton {
        icon: "󰌾"
        iconSize: 40
        iconColor: Theme.accent
        onClicked: Quickshell.execDetached(["loginctl", "lock-session"])
    }

    IconButton {
        icon: "󰗽"
        iconSize: 40
        iconColor: Theme.accent
        onClicked: Quickshell.execDetached(["hyprctl", "dispatch", "exit"])
    }
}
