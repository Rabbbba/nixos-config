import QtQuick
import Quickshell                  // for execDetached
import "../services"
import "../components"

/**
 * @brief Vertical stack of 4 power actions — lives inside the Nix-logo button's popout.
 *
 * Glyphs (top-to-bottom): poweroff, reboot, lock, logout. Each button uses a
 * two-step "arm + confirm" pattern: the first click swaps the icon to a check
 * mark for 3 s; a second click within that window actually triggers the action.
 * Falls back to idle if no second click arrives in time.
 */
Column {
    spacing: 8

    IconButton {
        id: btnPower
        icon: armed ? "✓" : "󰐥"
        iconSize: 40
        iconColor: armed ? Theme.color.alert : Theme.color.accent
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
        iconColor: armed ? Theme.color.alert : Theme.color.accent
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
        iconColor: armed ? Theme.color.alert : Theme.color.accent
        property bool armed: false
        property Timer _t: Timer {
            triggeredOnStart: false
            interval: 3000
            onTriggered: btnLock.armed = false
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
        iconColor: armed ? Theme.color.alert : Theme.color.accent
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
