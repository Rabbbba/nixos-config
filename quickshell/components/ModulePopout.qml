import QtQuick
import "../services"

/**
 * @brief Popout attached to a bar module — wires parentItem, panelWindow, and visibility.
 *
 * Wires the @ref Popout @c parentItem and @c panelWindow from a module
 * @ref wrapper, and binds visibility to the @ref services::Visibilities
 * singleton. Call sites only need to declare alignment, sizing, and content.
 *
 * Example:
 * @code
 * ModulePopout {
 *     wrapper: root
 *     name: "audio"
 *     alignment: "right"
 *     implicitWidth: 300
 *     implicitHeight: 200
 *     AudioPopup { anchors.fill: parent }
 * }
 * @endcode
 */
Popout {
    id: root

    /** Module instance this popout is attached to (provides parentItem + panelWindow). */
    required property var wrapper
    /** Unique popout identifier — see @ref services::Visibilities. */
    required property string name

    parentItem: wrapper
    panelWindow: wrapper.panelWindow
    visible: Visibilities.current === name
}
