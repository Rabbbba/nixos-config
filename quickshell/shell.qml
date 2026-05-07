//@ pragma DefaultEnv QS_NO_RELOAD_POPUP=1
//@ pragma DefaultEnv QS_DROP_EXPENSIVE_FONTS=1
//@ pragma DefaultEnv QSG_RENDER_LOOP=threaded

import Quickshell
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
        // Variants spawns one PanelWindow per matching screen.
        model: Quickshell.screens.filter(s => s.model === "AW3423DWF")
        PanelWindow {
            id: panel
            color: "transparent"
            implicitHeight: 40
            required property var modelData
            anchors {
                top: true
                left: true
                right: true
            }

            screen: modelData

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
                            width: 70
                            height: 200

                            PowerPopup {
                                anchors.centerIn: parent
                            }
                        }
                    }
                    Tags {
                        monitor: panel.modelData.name
                    }
                    Title {
                        monitor: panel.modelData.name
                    }
                    Layouts {
                        monitor: panel.modelData.name
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
    }
}
