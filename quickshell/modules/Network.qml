import QtQuick
import Quickshell.Io

ModuleWrapper {
    id: root

    Text {
        id: net
        property string state: "offline"   // "ethernet" | "wifi" | "offline"
        property string ssid: ""
        property int signal: 0

        color: Theme.fg1
        font.family: "Iosevka Nerd Font"
        font.pixelSize: 20

        text: {
            if (state === "ethernet") return "󰈀";
            if (state === "wifi")     return wifiIcon() + " " + ssid;
            return "󰤭";
        }

        function wifiIcon() {
            if (signal > 75) return "󰤨";
            if (signal > 50) return "󰤥";
            if (signal > 25) return "󰤢";
            if (signal > 0)  return "󰤟";
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

            // si aucune ligne ne sort (pas de connexion), on reset
            onExited: {
                if (net.state === "wifi" || net.state === "ethernet") return;
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
}
