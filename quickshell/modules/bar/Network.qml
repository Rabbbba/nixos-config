// qmllint disable missing-property
import QtQuick
import Quickshell.Networking
import "../../components"
import "../../services"

/**
 * @brief Bar module showing the active network connection (Ethernet / Wi-Fi / Offline).
 *
 * Reads NetworkManager state directly through @c Quickshell.Networking — no
 * nmcli polling. Renders one of: ethernet glyph, Wi-Fi bar-icon, or "offline"
 * glyph. Live throughput stays in the tooltip and @ref popouts::WifiPopup so
 * the bar remains compact.
 */
ModuleWrapper {
    id: root

    bgIdle: Theme.color.moduleBg
    bgHover: Theme.color.accent

    /** First WifiDevice found in @c Networking.devices, or null. */
    readonly property var wifiDevice: {
        for (const d of Networking.devices.values) {
            if (d.type === DeviceType.Wifi)
                return d;
        }
        return null;
    }

    /** First WiredDevice found in @c Networking.devices, or null. */
    readonly property var wiredDevice: {
        for (const d of Networking.devices.values) {
            if (d.type === DeviceType.Wired)
                return d;
        }
        return null;
    }

    /** Currently connected WifiNetwork on @ref wifiDevice, or null. */
    readonly property var activeWifi: {
        if (!root.wifiDevice)
            return null;
        for (const n of root.wifiDevice.networks.values) {
            if (n.connected)
                return n;
        }
        return null;
    }

    /** Connection kind: `"ethernet"`, `"wifi"`, or `"offline"`. */
    readonly property string netState: {
        if (root.wiredDevice && root.wiredDevice.connected)
            return "ethernet";
        if (root.activeWifi)
            return "wifi";
        return "offline";
    }

    /** SSID of the active Wi-Fi connection, or `""` when not on Wi-Fi. */
    readonly property string ssid: root.activeWifi ? root.activeWifi.name : ""

    /** Signal strength of the active Wi-Fi connection in [0, 100], or 0. */
    readonly property int signalPct: root.activeWifi ? Math.round(root.activeWifi.signalStrength * 100) : 0

    tooltip: {
        const traffic = "↓ " + NetworkSpeed.formatSpeed(NetworkSpeed.downloadKbps) + " · ↑ " + NetworkSpeed.formatSpeed(NetworkSpeed.uploadKbps);
        if (root.netState === "wifi")
            return "Wi-Fi: " + root.ssid + " (" + root.signalPct + "%) · " + traffic;
        if (root.netState === "ethernet")
            return "Ethernet · " + traffic;
        return "Offline · " + traffic;
    }

    onClicked: Visibilities.toggle("network")

    Row {
        StyledText {
            font.pixelSize: Theme.font.sizeLg
            color: root.hovered ? Theme.color.popupBg : Theme.color.text

            text: {
                if (root.netState === "ethernet")
                    return "󰈀";
                if (root.netState === "wifi") {
                    const pct = root.signalPct;
                    if (pct > 75)
                        return "󰤨";
                    if (pct > 50)
                        return "󰤥";
                    if (pct > 25)
                        return "󰤢";
                    if (pct > 0)
                        return "󰤟";
                    return "󰤯";
                }
                return "󰤭";
            }
        }
    }
}
