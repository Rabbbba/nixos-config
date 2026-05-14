//@ pragma DefaultEnv QS_NO_RELOAD_POPUP=1
//@ pragma DefaultEnv QS_DROP_EXPENSIVE_FONTS=1
//@ pragma DefaultEnv QSG_RENDER_LOOP=threaded

pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick.Effects
import QtQuick
import "modules"
import "popouts"
import "services"
import "components"

/**
 * @brief Top-level shell entry point — instantiates one bar per matching monitor.
 *
 * Per-monitor delegate (built via @c Variants → @c Scope):
 * - **panelBar**: interactive 40 px top bar on layer @c Top (captures clicks).
 *   Auto-reserves its 40 px exclusive zone via anchors.
 * - **panelBorder**: decorative full-screen border on layer @c Bottom
 *   (click-through). Sits BELOW app windows so it doesn't mask in-game
 *   overlays (Steam friends popups, Discord, etc.). Stays visible in the
 *   20 px reserved by the @ref components::ExclusionZone instances since
 *   nothing else is drawn there.
 * - **3× ExclusionZone**: reserve left/right/bottom 20 px in the
 *   layer-shell layout. Top is handled by @c panelBar itself.
 */
ShellRoot {
    settings.watchFiles: true

    Variants {
        model: Quickshell.screens.filter(s => s.model === "AW3423DWF")

        Scope {
            id: scope
            required property var modelData

            // ───────────────────── Bar interactive ─────────────────────
            // qmllint disable uncreatable-type
            PanelWindow {
                id: panelBar
                color: "transparent"
                WlrLayershell.layer: WlrLayer.Top
                implicitHeight: 40
                anchors {
                    top: true
                    left: true
                    right: true
                }
                screen: scope.modelData

                Rectangle {
                    anchors.fill: parent
                    color: Theme.windowBg

                    // Catch-all for clicks on empty bar space — closes the open popout.
                    // Placed as first child of the opaque Rectangle so it sits below
                    // the Row/Clock siblings that declare their own MouseAreas.
                    MouseArea {
                        anchors.fill: parent
                        enabled: Visibilities.current !== ""
                        onClicked: Visibilities.close()
                    }

                    Row {
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 10
                        Item {
                            id: nixBtn
                            width: 32
                            height: 32
                            property var panelWindow: panelBar

                            IconButton {
                                anchors.centerIn: parent
                                icon: ""
                                iconSize: 22
                                iconColor: Theme.text
                                onClicked: Visibilities.toggle("power")
                            }

                            ModulePopout {
                                wrapper: nixBtn
                                name: "power"
                                alignment: "left"
                                implicitWidth: 70
                                implicitHeight: 200

                                PowerPopup {
                                    anchors.centerIn: parent
                                }
                            }
                        }
                        Tags {
                            monitor: scope.modelData.name
                        }
                        Title {
                            monitor: scope.modelData.name
                        }
                        Layouts {
                            monitor: scope.modelData.name
                        }
                    }

                    Clock {
                        id: clockModule
                        panelWindow: panelBar
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    Row {
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 8
                        }
                        spacing: 12
                        SystemTray {
                            panelWindow: panelBar
                        }
                        Tidal {
                            id: tidalModule
                            panelWindow: panelBar
                        }
                        Gpu {
                            id: gpuModule
                            panelWindow: panelBar
                        }
                        Cpu {
                            id: cpuModule
                            panelWindow: panelBar
                        }
                        Ram {
                            id: ramModule
                            panelWindow: panelBar
                        }
                        Bluetooth {
                            id: btModule
                            panelWindow: panelBar
                        }
                        Network {
                            panelWindow: panelBar
                        }
                        Audio {
                            id: audioModule
                            panelWindow: panelBar
                        }
                    }
                }
            }

            // ───────────────────── Decorative border ───────────────────
            // qmllint disable uncreatable-type
            PanelWindow {
                id: panelBorder
                color: "transparent"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Bottom
                anchors {
                    top: true
                    left: true
                    right: true
                    bottom: true
                }
                screen: scope.modelData

                // Empty mask → fully click-through. The render stays visible
                // but no pointer event is captured by this surface.
                mask: Region {}

                Rectangle {
                    id: borderFill
                    anchors.fill: parent
                    color: Theme.windowBg
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        maskEnabled: true
                        maskInverted: true
                        maskSource: cutoutMask
                    }
                }

                Item {
                    id: cutoutMask
                    anchors.fill: parent
                    visible: false
                    layer.enabled: true

                    Rectangle {
                        x: 20
                        y: 40
                        width: parent.width - 40
                        height: parent.height - 60
                        radius: 24
                        color: "white"
                    }
                }
            }

            // ───────────────────── Popout container ────────────────────
            // Fullscreen PanelWindow hosting all popouts as Item children,
            // positioned via mapToGlobal/mapFromGlobal. Mask is empty at rest
            // (full click-through to panelBar below) and activates only the
            // visible popout zone(s) via nested Regions.
            // qmllint disable uncreatable-type
            PanelWindow {
                id: panelPopout
                color: "transparent"
                WlrLayershell.layer: WlrLayer.Top
                exclusionMode: ExclusionMode.Ignore
                anchors {
                    top: true
                    left: true
                    right: true
                    bottom: true
                }
                screen: scope.modelData

                // Mask = union of visible popout zones (Region default is Combine).
                // The root Region is intentionally empty (no x/y/width/height)
                // so panelPopout stays click-through at rest — clicks reach
                // panelBar (same Top layer, below in z-order) normally.
                //
                // DO NOT add a bar strip (e.g. `width: panelPopout.width; height: 40`)
                // here: it would absorb every click destined to panelBar.
                // HyprlandFocusGrab handles "click inside whitelisted window"
                // via `windows: [...]`, not via mask geometry.
                mask: Region {
                    Region {
                        x: calendarPopout.x
                        y: calendarPopout.y
                        width: calendarPopout.visible ? calendarPopout.implicitWidth : 0
                        height: calendarPopout.visible ? calendarPopout.implicitHeight : 0
                    }
                    Region {
                        x: cpuPopout.x
                        y: cpuPopout.y
                        width: cpuPopout.visible ? cpuPopout.implicitWidth : 0
                        height: cpuPopout.visible ? cpuPopout.implicitHeight : 0
                    }

                    Region {
                        x: audioPopout.x
                        y: audioPopout.y
                        width: audioPopout.visible ? audioPopout.implicitWidth : 0
                        height: audioPopout.visible ? audioPopout.implicitHeight : 0
                    }

                    Region {
                        x: gpuPopout.x
                        y: gpuPopout.y
                        width: gpuPopout.visible ? gpuPopout.implicitWidth : 0
                        height: gpuPopout.visible ? gpuPopout.implicitHeight : 0
                    }

                    Region {
                        x: ramPopout.x
                        y: ramPopout.y
                        width: ramPopout.visible ? ramPopout.implicitWidth : 0
                        height: ramPopout.visible ? ramPopout.implicitHeight : 0
                    }

                    Region {
                        x: tidalPopout.x
                        y: tidalPopout.y
                        width: tidalPopout.visible ? tidalPopout.implicitWidth : 0
                        height: tidalPopout.visible ? tidalPopout.implicitHeight : 0
                    }
                    Region {
                        x: btPopout.x
                        y: btPopout.y
                        width: btPopout.visible ? btPopout.implicitWidth : 0
                        height: btPopout.visible ? btPopout.implicitHeight : 0
                    }
                }

                // Whitelist panelPopout so clicks inside the popout retain focus.
                // Click elsewhere → grab clears. Closing on bar empty-space is
                // handled by the MouseArea catch-all in panelBar's Rectangle.
                HyprlandFocusGrab {
                    id: popoutGrab
                    windows: [panelPopout.QsWindow.window]
                    active: Visibilities.current !== ""
                    onCleared: Visibilities.close()
                }

                // ───────────────────── Calendar popout instance ──────
                // Child of panelPopout so QsWindow resolves correctly.
                PopoutItem {
                    id: calendarPopout
                    panelWindow: panelPopout
                    wrapper: clockModule
                    name: "calendar"
                    alignment: "center"
                    implicitWidth: 280
                    implicitHeight: 220

                    CalendarPopup {
                        anchors.centerIn: parent
                    }
                }

                PopoutItem {
                    id: cpuPopout
                    panelWindow: panelPopout
                    wrapper: cpuModule
                    name: "cpu"
                    alignment: "center"
                    implicitWidth: 360
                    implicitHeight: 230

                    CpuPopup {
                        anchors.fill: parent
                    }
                }

                PopoutItem {
                    id: audioPopout
                    panelWindow: panelPopout
                    wrapper: audioModule
                    name: "audio"
                    alignment: "right"
                    implicitWidth: 300
                    implicitHeight: 200

                    AudioPopup {
                        anchors.fill: parent
                    }
                }

                PopoutItem {
                    id: gpuPopout
                    panelWindow: panelPopout
                    wrapper: gpuModule
                    name: "gpu"
                    alignment: "center"
                    implicitWidth: 360
                    implicitHeight: 320

                    GpuPopup {
                        anchors.fill: parent
                    }
                }

                PopoutItem {
                    id: ramPopout
                    panelWindow: panelPopout
                    wrapper: ramModule
                    name: "ram"
                    alignment: "center"
                    implicitWidth: 320
                    implicitHeight: 230

                    RamPopup {
                        anchors.fill: parent
                    }
                }

                PopoutItem {
                    id: tidalPopout
                    panelWindow: panelPopout
                    wrapper: tidalModule
                    name: "tidal"
                    alignment: "center"
                    implicitHeight: 270
                    implicitWidth: 520

                    TidalPopup {
                        anchors.fill: parent
                        visible: tidalPopout.visible
                        popupVisible: tidalPopout.visible
                    }
                }

                PopoutItem {
                    id: btPopout
                    panelWindow: panelPopout
                    wrapper: btModule
                    name: "bluetooth"
                    alignment: "center"
                    implicitWidth: 320
                    implicitHeight: 320

                    BluetoothPopup {
                        anchors.fill: parent
                        bluetoothOn: btPopout.wrapper.bluetoothOn
                        onPowerToggleRequested: {
                            btModule.bluetoothOn = !btModule.bluetoothOn;
                            Quickshell.execDetached(["rfkill", btModule.bluetoothOn ? "unblock" : "block", "bluetooth"]);
                            btModule.refreshState();
                        }
                    }
                }

            }

            // ───────────────────── ExclusionZones ──────────────────────
            ExclusionZone {
                modelData: scope.modelData
                anchorSide: "left"
                exclusiveZoneSize: 20
            }
            ExclusionZone {
                modelData: scope.modelData
                anchorSide: "right"
                exclusiveZoneSize: 20
            }
            ExclusionZone {
                modelData: scope.modelData
                anchorSide: "bottom"
                exclusiveZoneSize: 20
            }
        }
    }
}
