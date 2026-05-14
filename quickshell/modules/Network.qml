import QtQuick
import Quickshell.Networking
import "../components"
import "../services"

/**
 * @brief Bar module showing the active network connection (Ethernet / Wi-Fi / Offline).
 *
 * Reads NetworkManager state directly through @c Quickshell.Networking — no
 * nmcli polling. Renders one of: ethernet glyph, Wi-Fi bar-icon, or "offline"
 * glyph, followed by the live download/upload speed pair from
 * @ref services::NetworkSpeed. Clicking opens the @ref popouts::WifiPopup
 * via @ref services::Visibilities.
 */
ModuleWrapper {
    id: root

    bgIdle: Theme.moduleBg
    bgHover: Theme.accent

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

    tooltip: netState === "wifi" ? "Wi-Fi: " + ssid + " (" + signalPct + "%)" : netState === "ethernet" ? "Ethernet" : "Offline"

    onClicked: Visibilities.toggle("network")

    // Worst-case width of a formatted speed string ("999Mb" at Md size).
    // Reserves a stable slot so the module width doesn't jiggle as digits
    // come and go. Above ~1 Gbps the format switches to "1.2Gb" which is
    // the same character count, so the slot stays valid up to 10 Gbps.
    TextMetrics {
        id: speedMetrics
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeMd
        text: "999Mb"
    }

    Row {
        // 8 px (vs the project-wide 6) so the down/up arrow glyphs get a
        // visible breathing gap before their value when the value uses the
        // full slot width (e.g. "135Mb" jams against the arrow at 6).
        spacing: 8

        StyledText {
            font.pixelSize: Theme.fontSizeLg
            color: root.hovered ? Theme.popupBg : Theme.text

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
