import QtQuick
import Quickshell.Io
import "../components"
import "../services"

/**
 * @brief Bar module showing the active network connection (Ethernet / Wi-Fi / Offline).
 *
 * Polls `nmcli` every 5 s for the active connection and, when on Wi-Fi, also
 * for the signal strength of the in-use AP. Renders one of: ethernet glyph,
 * Wi-Fi glyph + SSID, or "offline" glyph.
 *
 * Also shows live download/upload speed from @ref services::NetworkSpeed.
 */
ModuleWrapper {
    id: root

    bgIdle: Theme.moduleBg
    bgHover: Theme.accent

    tooltip: net.state === "wifi" ? "Wi-Fi: " + net.ssid + " (" + net.signal + "%)" : net.state === "ethernet" ? "Ethernet" : "Offline"

    // Worst-case width of a formatted speed string ("999.9M" at Md size).
    // Reserves a stable slot so the module width doesn't jiggle.
    TextMetrics {
        id: speedMetrics
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeMd
        text: "999.9M"
    }

    Row {
        spacing: 6

        StyledText {
            id: net
            property string state: "offline"   // "ethernet" | "wifi" | "offline"
            property string ssid: ""
            property int signal: 0

            font.pixelSize: Theme.fontSizeLg
            color: root.hovered ? Theme.popupBg : Theme.text

            text: {
                if (state === "ethernet")
                    return "󰈀";
                if (state === "wifi")
                    return wifiIcon();
                return "󰤭";
            }

            // 4-step bar icon based on signal %, plus an off-state glyph at 0.
            function wifiIcon() {
                if (signal > 75)
                    return "󰤨";
                if (signal > 50)
                    return "󰤥";
                if (signal > 25)
                    return "󰤢";
                if (signal > 0)
                    return "󰤟";
                return "󰤯";
            }

            Process {
                id: stateProc
                command: ["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION device | grep -E '(ethernet|wifi):connected:' | head -1"]
                running: false

                stdout: SplitParser {
                    splitMarker: "\n"
                    onRead: data => {
                        if (!data) {
                            net.state = "offline";
                            net.ssid = "";
                            return;
                        }
                        const parts = data.split(":");
                        const type = parts[0];
                        const conn = parts[2] || "";
                        if (type === "ethernet") {
                            net.state = "ethernet";
                            net.ssid = "";
                        } else if (type === "wifi") {
                            net.state = "wifi";
                            net.ssid = conn;
                            signalProc.running = false;
                            signalProc.running = true;
                        }
                    }
                }

                // If no line came out (no connection), reset to offline.
                onExited: {
                    if (net.state === "wifi" || net.state === "ethernet")
                        return;
                    net.state = "offline";
                }
            }

            Process {
                id: signalProc
                command: ["sh", "-c", "nmcli -t -f IN-USE,SIGNAL dev wifi | grep '^\\*' | cut -d: -f2"]
                running: false
                stdout: SplitParser {
                    splitMarker: "\n"
                    onRead: data => {
                        net.signal = parseInt(data) || 0;
                    }
                }
            }

            // Re-run the state probe every 5 s. Toggling running false→true
            // is how Quickshell's Process restarts.
            Timer {
                interval: 5000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    stateProc.running = false;
                    stateProc.running = true;
                }
            }
        }

        StyledText {
            text: ""
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeMd
            color: root.hovered ? Theme.popupBg : Theme.text
            height: parent.height
            verticalAlignment: Text.AlignVCenter
        }
        StyledText {
            text: NetworkSpeed.formatSpeed(NetworkSpeed.downloadKbps)
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeMd
            color: root.hovered ? Theme.popupBg : Theme.text
            width: speedMetrics.width
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideNone
            height: parent.height
            verticalAlignment: Text.AlignVCenter
        }

        StyledText {
            text: ""
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeMd
            color: root.hovered ? Theme.popupBg : Theme.text
            height: parent.height
            verticalAlignment: Text.AlignVCenter
        }
        StyledText {
            text: NetworkSpeed.formatSpeed(NetworkSpeed.uploadKbps)
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeMd
            color: root.hovered ? Theme.popupBg : Theme.text
            width: speedMetrics.width
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideNone
            height: parent.height
            verticalAlignment: Text.AlignVCenter
        }
    }
}
