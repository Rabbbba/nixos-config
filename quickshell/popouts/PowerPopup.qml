import QtQuick
import Quickshell                  // for execDetached
import "../modules"
import "../components"

// Vertical stack of 4 power actions, lives inside the Nix-logo button's Popout.
// Glyphs (in order): poweroff, reboot, lock, logout.
Column {
    spacing: 8

    IconButton {
        id: btnPower
        icon: armed ? "✓" : "󰐥"
        iconSize: 40
        iconColor: armed ? Theme.alert : Theme.accent
        property bool armed: false
        property Timer _t: Timer {
            triggeredOnStart: false
            interval: 3000
            onTriggered: btnPower.armed = false
        }
        onClicked: {
            if (armed)
                Quickshell.execDetached(["systemctl", "poweroff"]);
            else {
                armed = true;
                _t.start();
            }
        }
    }

    IconButton {
        id: btnReboot
        icon: armed ? "✓" : "󰜉"
        iconSize: 40
        iconColor: armed ? Theme.alert : Theme.accent
        property bool armed: false
        property Timer _t: Timer {
            triggeredOnStart: false
            interval: 3000
            onTriggered: btnReboot.armed = false
        }
        onClicked: {
            if (armed)
                Quickshell.execDetached(["systemctl", "reboot"]);
            else {
                armed = true;
                _t.start();
            }
        }
    }

    IconButton {
        id: btnLock
        icon: armed ? "✓" : "󰌾"
        iconSize: 40
        iconColor: armed ? Theme.alert : Theme.accent
        property bool armed: false
        property Timer _t: Timer {
            triggeredOnStart: false
            interval: 3000
            onTriggered: this.armed = false
        }
        onClicked: {
            if (armed)
                Quickshell.execDetached(["systemctl", "lock-session"]);
            else {
                armed = true;
                _t.start();
            }
        }
    }

    IconButton {
        id: btnLogout
        icon: armed ? "✓" : "󰗽"
        iconSize: 40
        iconColor: armed ? Theme.alert : Theme.accent
        property bool armed: false
        property Timer _t: Timer {
            triggeredOnStart: false
            interval: 3000
            onTriggered: btnLogout.armed = false
        }
        onClicked: {
            if (armed)
                Quickshell.execDetached(["hyprctl", "dispatch", "exit"]);
            else {
                armed = true;
                _t.start();
            }
        }
    }
}
