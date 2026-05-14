pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Networking
import "../modules"
import "../components"
import "../services"

/**
 * @brief Wi-Fi controller popup — power toggle, connected AP, scan & connect.
 *
 * Uses the Quickshell.Networking module (NetworkManager backend) directly,
 * so there is no nmcli Process spawning here. The toggle row drives
 * `Networking.wifiEnabled`; the active WifiDevice's networks are exposed
 * live and rendered as a sorted-by-signal list.
 *
 * For unknown secured networks, the row expands inline with an echo-mode
 * `TextInput`. On success the row collapses; on failure
 * (`NoSecrets`/`WifiAuthTimeout`) the error is shown beneath the input.
 *
 * The device scanner is enabled only while this popup is the visible one,
 * to avoid burning radio cycles when nobody is looking at the bar.
 */
Item {
    id: root
    anchors.fill: parent

    /** True while this popout is the currently visible one. */
    readonly property bool popupVisible: Visibilities.current === "network"

    /** First WifiDevice found in `Networking.devices`, or null. */
    readonly property var wifiDevice: {
        const devs = Networking.devices.values;
        for (const d of devs) {
            if (d.type === DeviceType.Wifi)
                return d;
        }
        return null;
    }

    /** The currently connected WifiNetwork on @ref wifiDevice, or null. */
    readonly property var activeNetwork: {
        if (!root.wifiDevice)
            return null;
        for (const n of root.wifiDevice.networks.values) {
            if (n.connected)
                return n;
        }
        return null;
    }

    /**
     * Visible networks, excluding the connected one, sorted by signal strength
     * descending and capped at 12 entries to keep the popout bounded in
     * crowded environments.
     */
    readonly property var availableNetworks: {
        if (!root.wifiDevice)
            return [];
        const list = [];
        for (const n of root.wifiDevice.networks.values) {
            if (!n.name || n.name.length === 0)
                continue;
            if (n.connected)
                continue;
            list.push(n);
        }
        list.sort((a, b) => b.signalStrength - a.signalStrength);
        return list.slice(0, 12);
    }

    /** Name of the network whose password input is currently expanded, or "". */
    property string expandedSsid: ""

    /**
     * Natural height of the column — exposed so the hosting PopoutItem can
     * size itself to the actual content instead of using a fixed
     * implicitHeight that leaves a large empty area when only a few APs
     * are visible.
     */
    readonly property real preferredHeight: layoutColumn.implicitHeight

    // Drive the scanner only while the popup is open AND the radio is on.
    // NetworkManager expects scan requests to be user-driven, and a running
    // scanner keeps the device active even when no one is looking.
    Binding {
        target: root.wifiDevice
        property: "scannerEnabled"
        value: root.popupVisible && Networking.wifiEnabled
        when: root.wifiDevice !== null
    }

    /**
     * Pick the 4-bar Wi-Fi NerdFont glyph matching a signal percentage.
     * @param pct Signal strength in [0, 100].
     */
    function wifiIcon(pct: int): string {
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

    Column {
        id: layoutColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 10

        SectionHeader {
            text: "Wi-Fi"
        }

        // ── Power toggle row ─────────────────────────────────────────────
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
                text: Networking.wifiEnabled ? "󰤨  Wi-Fi" : "󰤯  Wi-Fi"
                color: Theme.text
            }

            Rectangle {
                id: switchTrack
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 40
                height: 22
                radius: height / 2
                color: Networking.wifiEnabled ? Theme.accent : Theme.moduleBg
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
                    x: Networking.wifiEnabled ? parent.width - width - 3 : 3
                    color: Networking.wifiEnabled ? Theme.popupBg : Theme.text

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
                onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
            }
        }

        // ── Connected section ────────────────────────────────────────────
        SectionHeader {
            text: "Connected"
            visible: Networking.wifiEnabled && root.activeNetwork !== null
        }

        Item {
            width: parent.width
            height: 28
            visible: Networking.wifiEnabled && root.activeNetwork !== null

            HoverHandler {
                id: connectedHover
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: -4
                radius: 6
                color: Theme.moduleBg
                opacity: connectedHover.hovered ? 0.6 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.animFast
                    }
                }
            }

            StyledText {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    if (!root.activeNetwork)
                        return "";
                    const pct = Math.round(root.activeNetwork.signalStrength * 100);
                    return root.wifiIcon(pct) + "  " + root.activeNetwork.name;
                }
                color: Theme.accent
                elide: Text.ElideRight
                width: parent.width - 28
            }

            StyledText {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: root.activeNetwork !== null && root.activeNetwork.security !== WifiSecurityType.Open
                text: "󰍁"
                color: Theme.textMuted
                font.pixelSize: Theme.fontSizeSm
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.activeNetwork)
                        root.activeNetwork.disconnect();
                }
            }
        }

        // ── Available section ────────────────────────────────────────────
        SectionHeader {
            text: "Available"
            visible: Networking.wifiEnabled
        }

        Repeater {
            model: Networking.wifiEnabled ? root.availableNetworks : []

            delegate: Item {
                id: apRow
                required property var modelData

                readonly property bool secured: modelData.security !== WifiSecurityType.Open
                readonly property bool expanded: root.expandedSsid === modelData.name
                readonly property int pct: Math.round(modelData.signalStrength * 100)

                property string passwordText: ""
                property string lastError: ""

                width: parent.width
                height: expanded ? (70 + (lastError.length > 0 ? 18 : 0)) : 28

                Behavior on height {
                    NumberAnimation {
                        duration: Theme.animFast
                    }
                }

                // NetworkManager emits this on auth failure / missing PSK.
                // NoSecrets means we tried the cached path and there was nothing
                // cached — switch to the password prompt automatically.
                Connections {
                    target: apRow.modelData
                    function onConnectionFailed(reason) {
                        if (reason === ConnectionFailReason.NoSecrets) {
                            apRow.lastError = "";
                            root.expandedSsid = apRow.modelData.name;
                        } else if (reason === ConnectionFailReason.WifiAuthTimeout) {
                            apRow.lastError = "Wrong password";
                        } else {
                            apRow.lastError = ConnectionFailReason.toString(reason);
                        }
                    }
                }

                // Collapse and clear state once we’re actually connected.
                Connections {
                    target: apRow.modelData
                    function onConnectedChanged() {
                        if (apRow.modelData.connected) {
                            root.expandedSsid = "";
                            apRow.passwordText = "";
                            apRow.lastError = "";
                        }
                    }
                }

                // Header row — always visible
                Item {
                    id: headerRow
                    width: parent.width
                    height: 28

                    HoverHandler {
                        id: apHover
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -4
                        radius: 6
                        color: Theme.moduleBg
                        opacity: apHover.hovered ? 0.6 : 0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.animFast
                            }
                        }
                    }

                    StyledText {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.wifiIcon(apRow.pct) + "  " + apRow.modelData.name
                        color: apRow.modelData.stateChanging ? Theme.accent : Theme.text
                        elide: Text.ElideRight
                        width: parent.width - 28
                    }

                    StyledText {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        visible: apRow.secured
                        text: "󰍁"
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontSizeSm
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (apRow.expanded) {
                                root.expandedSsid = "";
                                return;
                            }
                            if (!apRow.secured || apRow.modelData.known) {
                                // Open or known network — try the cached path first.
                                // NoSecrets failure will reopen the prompt automatically.
                                apRow.lastError = "";
                                apRow.modelData.connect();
                            } else {
                                apRow.passwordText = "";
                                apRow.lastError = "";
                                root.expandedSsid = apRow.modelData.name;
                            }
                        }
                    }
                }

                // Password input row — visible only when this row is expanded
                Item {
                    id: pwRow
                    width: parent.width
                    height: 36
                    anchors.top: headerRow.bottom
                    anchors.topMargin: 4
                    visible: apRow.expanded

                    Rectangle {
                        id: pwBg
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 90
                        height: 30
                        radius: 4
                        color: Theme.moduleBg
                        border.color: pwField.activeFocus ? Theme.accent : Theme.border
                        border.width: 1

                        TextInput {
                            id: pwField
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Password
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSm
                            selectByMouse: true
                            clip: true
                            activeFocusOnTab: true
                            text: apRow.passwordText
                            onTextChanged: apRow.passwordText = text
                            onAccepted: apRow.tryConnect()
                            Keys.onEscapePressed: root.expandedSsid = ""
                            onVisibleChanged: {
                                if (visible)
                                    Qt.callLater(() => pwField.forceActiveFocus());
                            }
                        }
                    }

                    Rectangle {
                        id: connectBtn
                        anchors.right: cancelBtn.left
                        anchors.rightMargin: 4
                        anchors.verticalCenter: parent.verticalCenter
                        width: 56
                        height: 30
                        radius: 4
                        color: connectMa.containsMouse ? Theme.accent : Theme.moduleBg
                        border.color: Theme.border
                        border.width: 1
                        opacity: apRow.passwordText.length > 0 ? 1.0 : 0.5

                        StyledText {
                            anchors.centerIn: parent
                            text: "Connect"
                            color: connectMa.containsMouse ? Theme.popupBg : Theme.text
                            font.pixelSize: Theme.fontSizeSm
                        }

                        MouseArea {
                            id: connectMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: apRow.tryConnect()
                        }
                    }

                    Rectangle {
                        id: cancelBtn
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 28
                        height: 30
                        radius: 4
                        color: cancelMa.containsMouse ? Theme.alert : Theme.moduleBg
                        border.color: Theme.border
                        border.width: 1

                        StyledText {
                            anchors.centerIn: parent
                            text: "×"
                            color: cancelMa.containsMouse ? Theme.popupBg : Theme.text
                            font.pixelSize: Theme.fontSizeMd
                        }

                        MouseArea {
                            id: cancelMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.expandedSsid = ""
                        }
                    }
                }

                // Error line — visible only on a failed attempt while expanded
                StyledText {
                    anchors.top: pwRow.bottom
                    anchors.topMargin: 2
                    anchors.left: parent.left
                    visible: apRow.expanded && apRow.lastError.length > 0
                    text: apRow.lastError
                    color: Theme.alert
                    font.pixelSize: Theme.fontSizeSm
                }

                function tryConnect() {
                    if (apRow.passwordText.length === 0)
                        return;
                    apRow.lastError = "";
                    apRow.modelData.connectWithPsk(apRow.passwordText);
                }
            }
        }

        // Placeholder when the scan is empty
        StyledText {
            visible: Networking.wifiEnabled && root.availableNetworks.length === 0
            text: root.wifiDevice && root.wifiDevice.scannerEnabled ? "Scanning…" : "No networks"
            color: Theme.textMuted
            font.pixelSize: Theme.fontSizeSm
        }

        // Placeholder when the radio is off
        StyledText {
            visible: !Networking.wifiEnabled
            text: "Wi-Fi disabled"
            color: Theme.textMuted
            font.pixelSize: Theme.fontSizeSm
        }
    }
}
