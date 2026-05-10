//@ pragma DefaultEnv QS_NO_RELOAD_POPUP=1
//@ pragma DefaultEnv QS_DROP_EXPENSIVE_FONTS=1
//@ pragma DefaultEnv QSG_RENDER_LOOP=threaded

pragma ComponentBehavior: Bound
import Quickshell
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
                            panelWindow: panelBar
                        }
                        Gpu {
                            panelWindow: panelBar
                        }
                        Cpu {
                            panelWindow: panelBar
                        }
                        Ram {
                            panelWindow: panelBar
                        }
                        Bluetooth {
                            panelWindow: panelBar
                        }
                        Network {
                            panelWindow: panelBar
                        }
                        Audio {
                            panelWindow: panelBar
                        }
                    }
                }
            }

            // ───────────────────── Decorative border ───────────────────
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
