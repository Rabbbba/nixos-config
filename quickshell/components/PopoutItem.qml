import QtQuick
import "../services"

/**
 * @brief Popout anchored under a bar module — Item-based, no PopupWindow.
 *
 * Replaces the old ModulePopout → Popout (PopupWindow) chain. The popout
 * lives as an Item child inside the fullscreen panelPopout in shell.qml.
 * Position is computed by mapping the wrapper's coordinates into the
 * panel's content space. Visibility binds to Visibilities.current.
 *
 * Open/close animation: opacity 0→1 + scale 0.96→1 on visible toggle.
 */
Item {
    id: root

    /** Module instance this popout is attached to (provides parentItem). */
    required property var wrapper
    /** Target PanelWindow that hosts all popouts (panelPopout in shell.qml). */
    required property var panelWindow
    /** Unique popout identifier — see @ref services::Visibilities. */
    required property string name

    /** Inner padding between the panel border and the content slot. */
    property int padding: 14

    /** Horizontal alignment relative to wrapper. Valid: "left", "center", "right". */
    property string alignment: "center"

    // Visibility bound to the singleton — only this popout shows when active.
    visible: Visibilities.current === name

    // ── Positioning ────────────────────────────────────────────────
    // Calculated synchronously in onVisibleChanged so x/y are ready
    // immediately for mask binding (no 16ms delay gap).
    property real popoutX: 0  ///< Internal x position set by _recalcPosition().
    property real popoutY: 0  ///< Internal y position set by _recalcPosition().
    x: popoutX
    y: popoutY

    function _recalcPosition() {
        const localX = alignment === "center" ? wrapper.width / 2 : alignment === "right" ? wrapper.width : 0;
        // Wrapper → screen (absolute) → panelWindow.contentItem
        // mapToGlobal/mapFromGlobal use absolute screen coords — independent
        // of QsWindow scene graph separation.
        const g = wrapper.mapToGlobal(localX, 0);
        const mapped = panelWindow.contentItem.mapFromGlobal(g.x, g.y);
        popoutX = mapped.x - (alignment === "center" ? implicitWidth / 2 : alignment === "right" ? implicitWidth : 0);

        const gY = wrapper.mapToGlobal(0, wrapper.height);
        const mappedY = panelWindow.contentItem.mapFromGlobal(gY.x, gY.y);
        popoutY = mappedY.y + 10;  // 10px gap below the module
    }

    onVisibleChanged: {
        if (visible) {
            _recalcPosition();
        } else {
            popoutX = 0;
            popoutY = 0;
        }
    }

    // ── Inner panel with animation ─────────────────────────────────
    Rectangle {
        id: panel
        anchors.fill: parent
        color: Theme.popupBg
        radius: 10
        border.color: Theme.border
        border.width: 1

        opacity: root.visible ? 1 : 0
        scale: root.visible ? 1 : 0.96
        transformOrigin: Item.Center

        Behavior on opacity { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
        Behavior on scale  { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }

        Item {
            id: container
            anchors.fill: parent
            anchors.margins: root.padding
        }
    }

    // ── Default property ───────────────────────────────────────────
    // Anything declared inside PopoutItem {} is reparented into `container`.
    default property alias contents: container.data
}
