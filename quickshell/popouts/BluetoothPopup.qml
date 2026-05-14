import QtQuick
import Quickshell
import Quickshell.Io
import "../modules"
import "../components"
import "../services"

/**
 * @brief Bluetooth controller popup — power toggle, paired list, live scan.
 *
 * - Toggle row: emits @ref powerToggleRequested; the parent module owns the
 *   actual rfkill command and optimistic state update.
 * - Paired devices: polled every 3 s via two `bluetoothctl devices Paired/Connected`
 *   processes, merged into a single annotated list. Click toggles connection.
 * - Available devices: discovered live by holding a long-running `bluetoothctl`
 *   subprocess open (only while the popup is visible AND the adapter is on),
 *   writing `scan on` on its stdin, and parsing `[NEW]/[DEL] Device <addr>` lines
 *   from its stdout. Click pairs + connects the device.
 *
 * Devices already in the paired list are filtered out of the available list
 * to avoid duplicates.
 */
Item {
    id: root
    anchors.fill: parent

    /** Mirror of @ref modules::Bluetooth::bluetoothOn — drives the toggle label. */
    property bool bluetoothOn: false

    /**
     * Emitted when the user clicks the on/off row. The parent module
     * owns the actual rfkill command + optimistic state update.
     */
    signal powerToggleRequested

    /**
     * Paired device list. Each entry: `{addr: string, name: string, connected: bool}`.
     * Rebuilt on every paired-poll completion by merging in the connected set.
     */
    property var devices: []
    /** Set of MAC addresses currently connected. */
    property var connectedAddrs: ({})

    /**
     * Live scan results. Each entry: `{addr: string, name: string}`. Filtered
     * to exclude addresses present in @ref devices.
     */
    property var available: []

    /** True while this popout is the visible one — drives scanProc lifecycle. */
    readonly property bool popupVisible: Visibilities.current === "bluetooth"

    /**
     * Natural height of the layout column — the hosting PopoutItem binds its
     * `implicitHeight` to this so the box only grows as much as the actual
     * content needs (toggle + paired list + scan results).
     */
    readonly property real preferredHeight: layoutColumn.implicitHeight

    /**
     * Re-runs the connected/paired pollers. The connected pass triggers
     * the paired pass on completion so the merged list is consistent.
     */
    function refreshDevices(): void {
        connectedProc.running = false;
        connectedProc.running = true;
    }

    // ─── Paired pollers ───────────────────────────────────────────────
    // `bluetoothctl devices Paired` lines look like:
    //   Device 30:7E:CB:7B:08:7B Buds3 Pro
    // We split on the first space after `Device ` so multi-word names stay intact.
    Process {
        id: pairedProc
        command: ["sh", "-c", "bluetoothctl devices Paired"]
        property var buffer: []

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const line = data.trim();
                if (!line.startsWith("Device "))
                    return;
                const rest = line.slice(7);
                const sp = rest.indexOf(" ");
                if (sp < 0)
                    return;
                const addr = rest.slice(0, sp);
                const name = rest.slice(sp + 1);
                pairedProc.buffer.push({
                    addr: addr,
                    name: name,
                    connected: !!root.connectedAddrs[addr]
                });
            }
        }

        onStarted: pairedProc.buffer = []
        onExited: {
            root.devices = pairedProc.buffer;
        }
    }

    Process {
        id: connectedProc
        command: ["sh", "-c", "bluetoothctl devices Connected"]
        property var buffer: ({})

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const line = data.trim();
                if (!line.startsWith("Device "))
                    return;
                const rest = line.slice(7);
                const sp = rest.indexOf(" ");
                if (sp < 0)
                    return;
                connectedProc.buffer[rest.slice(0, sp)] = true;
            }
        }

        onStarted: connectedProc.buffer = ({})
        onExited: {
            root.connectedAddrs = connectedProc.buffer;
            // Connected set is fresh — repoll Paired so we annotate correctly.
            pairedProc.running = false;
            pairedProc.running = true;
        }
    }

    Timer {
        interval: 3000
        running: root.bluetoothOn && root.popupVisible
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshDevices()
    }

    // Single-shot refresh fired after a connect/disconnect/pair action.
    Timer {
        id: postActionTimer
        interval: 1500
        repeat: false
        onTriggered: root.refreshDevices()
    }

    // ─── Live scan ────────────────────────────────────────────────────
    // We hold an interactive bluetoothctl subprocess open as long as the
    // popup is visible and the adapter is on. On start, we send `scan on`
    // (after a short delay so bluetoothctl finishes its preamble); on stop,
    // killing the process implicitly cancels the discovery.
    Process {
        id: scanProc
        command: ["bluetoothctl"]
        stdinEnabled: true
        running: root.bluetoothOn && root.popupVisible

        onStarted: scanStartTimer.restart()
        onRunningChanged: {
            if (!running)
                root.available = [];
        }

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                // Strip ANSI color escapes that bluetoothctl emits even on a pipe.
                const cleaned = data.replace(/\x1b\[[0-9;]*[a-zA-Z]/g, "").replace(/\r/g, "").trim();
                const m = cleaned.match(/^\[(NEW|DEL)\]\s+Device\s+([0-9A-F:]{17})\s*(.*)$/);
                if (!m)
                    return;
                const event = m[1];
                const addr = m[2];
                const name = m[3];

                // Skip already-paired devices — the paired section handles them.
                if (root.devices.some(d => d.addr === addr))
                    return;

                if (event === "NEW") {
                    const idx = root.available.findIndex(d => d.addr === addr);
                    const display = name || addr;
                    if (idx >= 0) {
                        const list = root.available.slice();
                        list[idx] = {
                            addr: addr,
                            name: display
                        };
                        root.available = list;
                    } else {
                        root.available = [...root.available, {
                            addr: addr,
                            name: display
                        }];
                    }
                } else if (event === "DEL") {
                    root.available = root.available.filter(d => d.addr !== addr);
                }
            }
        }
    }

    // bluetoothctl prints a preamble before its prompt is ready; sending
    // `scan on` immediately on `started` is racy. 250 ms is a safe margin.
    Timer {
        id: scanStartTimer
        interval: 250
        repeat: false
        onTriggered: {
            if (scanProc.running)
                scanProc.write("scan on\n");
        }
    }

    // ─── Layout ───────────────────────────────────────────────────────
    Column {
        id: layoutColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 12

        SectionHeader {
            text: "Bluetooth"
        }

        // ── Power toggle row ─────────────────────────────────────────
        Item {
            width: parent.width
            height: 32

            HoverHandler {
                id: toggleHover
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: -4
                radius: 6
                color: Theme.moduleBg
                opacity: toggleHover.hovered ? 0.6 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.animFast
                    }
                }
            }

            StyledText {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: root.bluetoothOn ? "󰂯  Bluetooth" : "󰂲  Bluetooth"
                color: Theme.text
            }

            // iOS-style toggle: rounded track + sliding thumb. Driven entirely
            // by the @ref bluetoothOn binding — clicking the row only emits the
            // signal, the parent module performs the optimistic flip.
            Rectangle {
                id: switchTrack
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 40
                height: 22
                radius: height / 2
                color: root.bluetoothOn ? Theme.accent : Theme.moduleBg
                border.color: Theme.border
                border.width: 1

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animFast
                    }
                }

                Rectangle {
                    width: 16
                    height: 16
                    radius: height / 2
                    anchors.verticalCenter: parent.verticalCenter
                    x: root.bluetoothOn ? parent.width - width - 3 : 3
                    color: root.bluetoothOn ? Theme.popupBg : Theme.text

                    Behavior on x {
                        NumberAnimation {
                            duration: Theme.animFast
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animFast
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.powerToggleRequested()
            }
        }

        // ── Paired devices section ───────────────────────────────────
        SectionHeader {
            text: "Paired"
            visible: root.bluetoothOn
        }

        Repeater {
            model: root.bluetoothOn ? root.devices : []

            delegate: Item {
                id: pairedRow
                required property var modelData

                width: parent.width
                height: 28

                HoverHandler {
                    id: pairedHover
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -4
                    radius: 6
                    color: Theme.moduleBg
                    opacity: pairedHover.hovered ? 0.6 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.animFast
                        }
                    }
                }

                StyledText {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: (pairedRow.modelData.connected ? "● " : "○ ") + pairedRow.modelData.name
                    color: pairedRow.modelData.connected ? Theme.accent : Theme.text
                    elide: Text.ElideRight
                    width: parent.width - 16
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        const action = pairedRow.modelData.connected ? "disconnect" : "connect";
                        Quickshell.execDetached(["bluetoothctl", action, pairedRow.modelData.addr]);
                        postActionTimer.restart();
                    }
                }
            }
        }

        StyledText {
            visible: root.bluetoothOn && root.devices.length === 0
            text: "No paired devices"
            color: Theme.textMuted
            font.pixelSize: Theme.fontSizeSm
        }

        // ── Available devices section ────────────────────────────────
        SectionHeader {
            text: "Available"
            visible: root.bluetoothOn
        }

        Repeater {
            model: root.bluetoothOn ? root.available : []

            delegate: Item {
                id: availRow
                required property var modelData

                width: parent.width
                height: 28

                HoverHandler {
                    id: availHover
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -4
                    radius: 6
                    color: Theme.moduleBg
                    opacity: availHover.hovered ? 0.6 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.animFast
                        }
                    }
                }

                StyledText {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "+ " + availRow.modelData.name
                    color: Theme.textMuted
                    elide: Text.ElideRight
                    width: parent.width - 16
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        // Pair, trust, then connect — chained because each
                        // step depends on the previous one succeeding.
                        Quickshell.execDetached(["sh", "-c", "bluetoothctl pair " + availRow.modelData.addr + " && bluetoothctl trust " + availRow.modelData.addr + " && bluetoothctl connect " + availRow.modelData.addr]);
                        postActionTimer.restart();
                    }
                }
            }
        }

        StyledText {
            visible: root.bluetoothOn && root.available.length === 0
            text: scanProc.running ? "Scanning…" : ""
            color: Theme.textMuted
            font.pixelSize: Theme.fontSizeSm
        }
    }
}
