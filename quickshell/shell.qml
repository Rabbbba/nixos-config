//@ pragma DefaultEnv QS_NO_RELOAD_POPUP=1
//@ pragma DefaultEnv QS_DROP_EXPENSIVE_FONTS=1
//@ pragma DefaultEnv QSG_RENDER_LOOP=threaded

import Quickshell
import QtQuick
import "modules"
import "services"
import "components"

// Top bar — lives only on the primary monitor (DP-2).
// Layout is 3 anchored groups inside the bar Rectangle:
//   left Row    : Nix-logo button (Power popup) → Tags → Title → Layouts
//   centered    : Clock (Calendar popup)
//   right Row   : Tidal → Ram → Cpu → Network → Audio
ShellRoot {
    settings.watchFiles: true

    Variants {
        // Variants spawns one PanelWindow per matching screen.
        model: Quickshell.screens.filter(s => s.name === "DP-2")
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

                        Popout {
                            id: powerPop
                            parentItem: nixBtn
                            panelWindow: panel
                            alignement: "left"
                            width: 70
                            height: 200
                            visible: Visibilities.current === "power"

                            Power {
                                anchors.centerIn: parent
                            }
                        }
                    }
                    Tags {
                        monitor: modelData.name
                    }
                    Title {
                        monitor: modelData.name
                    }
                    Layouts {
                        monitor: modelData.name
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
                    Tidal {
                        panelWindow: panel
                    }
                    Ram {
                        panelWindow: panel
                    }
                    Cpu {
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
