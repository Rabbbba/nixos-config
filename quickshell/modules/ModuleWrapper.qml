import QtQuick
import "../components"
import "../services"

/**
 * @brief Common bar-module shell: rounded background, hover swap, click/wheel.
 *
 * Provides the standard look and behaviour shared by every bar module
 * (Cpu, Ram, Audio, Network, Clock, Tidal, Title, Layouts, …):
 * a rounded rectangle background that swaps color on hover, optional tooltip,
 * and click + wheel signals routed from an internal @c MouseArea. The
 * concrete content (icon + label) is declared as a child of the wrapper.
 */
Item {
    id: root

    /** Emitted when the user clicks anywhere inside the module. */
    signal clicked
    /**
     * Emitted on mouse-wheel inside the module.
     * @param angleDelta The wheel angle delta as a Qt @c point (use @c y for vertical).
     */
    signal wheel(point angleDelta)

    /** Tooltip text shown after a 300 ms hover. Empty disables the tooltip. */
    property string tooltip: ""
    /** Reference to the @c PanelWindow this module lives in (needed for popouts). */
    property var panelWindow: null

    // Default property: child items are reparented into the inner content slot.
    default property alias _content: inner.data
    /** Background color when hovered. */
    property color bgHover: Theme.popupBg
    /** Background color when idle. */
    property color bgIdle: Theme.moduleBg
    /** True while the mouse is over the module (alias for the inner MouseArea). */
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
