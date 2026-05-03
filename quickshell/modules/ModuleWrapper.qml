import QtQuick
import "../components"
import "../services"

// Common bar-module shell: rounded background that swaps color on hover,
// click + wheel signals, content slot. Used by Cpu, Ram, Audio, Network,
// Clock, Tidal, Title, Layouts.
Item {
    id: root
    signal clicked
    signal wheel(point angleDelta)

    property string tooltip: ""
    property var panelWindow: null

    // Public API (configurable from the outside).
    default property alias _content: inner.data
    property color bgHover: Theme.popupBg
    property color bgIdle: Theme.moduleBg
    property alias hovered: ma.containsMouse

    implicitWidth: inner.childrenRect.width + 16
    implicitHeight: 30

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: ma.containsMouse ? root.bgHover : root.bgIdle
        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
            }
        }
    }

    Item {
        id: inner
        anchors.centerIn: parent
        width: childrenRect.width
        height: childrenRect.height
    }

    Timer {
        id: tooltipTimer
        interval: 300
        onTriggered: tt.visible = true
    }

    Tooltip {
        id: tt
        parentItem: root
        panelWindow: root.panelWindow
        text: root.tooltip
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
        onWheel: w => root.wheel(w.angleDelta)

        onEntered: if (root.tooltip !== "")
            tooltipTimer.start()
        onExited: {
            tooltipTimer.stop();
            tt.visible = false;
        }
    }
}
