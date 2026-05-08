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

// Top bar — lives only on the primary monitor (DP-1).
// Layout is 3 anchored groups inside the bar Rectangle:
//   left Row    : Nix-logo button (Power popup) → Tags → Title → Layouts
//   centered    : Clock (Calendar popup)
//   right Row   : Tidal → Gpu → Cpu → Ram → Network → Audio
ShellRoot {
    settings.watchFiles: true

    Variants {
        // Variants spawns one Scope (containing PanelWindow + 4 ExclusionZones)
        // per matching screen. Caelestia pattern — single delegate per Variants.
        model: Quickshell.screens.filter(s => s.model === "AW3423DWF")

        Scope {
            id: scope
            required property var modelData

            PanelWindow {
                id: panel
                color: "transparent"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Top
                anchors {
                    top: true
                    left: true
                    right: true
                    bottom: true
                }

                // Input mask : seuls les 40px du top (la bar) capturent les clics.
                // Le reste de la window est transparent ET clickthrough.
                mask: Region {
                    item: cutoutMask
                    intersection: Intersection.Xor
                }

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

                // Mask source : MultiEffect sample maskSource à la MÊME position
                // que la source (borderFill), donc cutoutMask doit aussi spanner
                // toute la zone du panel. Le Rectangle blanc à l'intérieur
                // matérialise la zone du trou (alpha=1 dedans, 0 ailleurs).
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

                screen: scope.modelData

                Rectangle {
                    anchors {
                        top: parent.top
                        right: parent.right
                        left: parent.left
                    }
                    height: 40
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
                            property var panelWindow: panel

                            IconButton {
                                anchors.centerIn: parent
                                icon: ""
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
                        panelWindow: panel
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
                            panelWindow: panel
                        }
                        Tidal {
                            panelWindow: panel
                        }
                        Gpu {
                            panelWindow: panel
                        }
                        Cpu {
                            panelWindow: panel
                        }
                        Ram {
                            panelWindow: panel
                        }
                        Network {
                            panelWindow: panel
                        }
                        Audio {
                            panelWindow: panel
                        }
                    }
                }
            }
            ExclusionZone {
                modelData: scope.modelData
                anchorSide: "bottom"
                exclusiveZoneSize: 20
            }
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
                anchorSide: "top"
                exclusiveZoneSize: 40
            }
        }
    }
}
