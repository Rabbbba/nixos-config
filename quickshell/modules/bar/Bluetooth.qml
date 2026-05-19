import QtQuick
import Quickshell.Io
import "../../components"
import "../../services"

/**
 * @brief Bar module showing Bluetooth power state.
 *
 * Polls `rfkill list bluetooth` every 5 s for the `Soft blocked:` field —
 * deterministic on systems with multiple Bluetooth controllers, unlike
 * `bluetoothctl show` which picks an arbitrary controller. Clicking toggles
 * the Bluetooth popout via @c Visibilities.
 */
ModuleWrapper {
    id: root

    bgIdle: Theme.moduleBg
    bgHover: Theme.accent

    tooltip: "Bluetooth: " + (bluetoothOn ? "On" : "Off")

    /** True when at least one rfkill bluetooth entry is unblocked. */
    property bool bluetoothOn: false

    Process {
        id: btProc
        command: ["rfkill", "list", "bluetooth"]

        property bool sawUnblocked: false

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const line = data.trim().toLowerCase();
                // Any "soft blocked: no" line means at least one BT
                // controller is unblocked → consider the system "on".
                if (line.startsWith("soft blocked:") && line.endsWith("no"))
                    btProc.sawUnblocked = true;
            }
        }

        onStarted: btProc.sawUnblocked = false
        onExited: root.bluetoothOn = btProc.sawUnblocked
    }

    function refreshState() {
        btProc.running = false;
        btProc.running = true;
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshState()
    }

    StyledText {
        text: root.bluetoothOn ? "󰂯" : "󰂲"
        font.pixelSize: Theme.fontSizeLg
        color: root.hovered ? Theme.popupBg : Theme.text
    }

    onClicked: Visibilities.toggle("bluetooth")
}
