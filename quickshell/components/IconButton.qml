// qmllint disable missing-property
import QtQuick
import "../services"

/**
 * @brief Round icon button with a centered NerdFont glyph and hover background.
 *
 * Used for Power actions, Tidal transport controls, the Nix logo button, etc.
 * Emits @ref clicked when the user clicks on it.
 *
 * @warning Never include a trailing space in @ref icon — the centered Text
 * counts the space in its width and the visible glyph drifts to the left.
 */
Rectangle {
    id: root

    /** NerdFont glyph to display (e.g. "󰐎"). No trailing space. */
    property string icon: ""
    /** Glyph size in pixels. */
    property int iconSize: 18
    /** Glyph color. Defaults to Theme.color.text. */
    property color iconColor: Theme.color.text
    /** Diameter of the circular button in pixels. */
    property int diameter: 40

    /** Emitted when the user clicks the button. */
    signal clicked

    width: diameter
    height: diameter
    radius: diameter / 2
    color: ma.containsMouse ? Theme.color.moduleBg : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: Theme.anim.fast
        }
    }

    StyledText {
        anchors.centerIn: parent
        text: root.icon
        color: root.iconColor
        font.pixelSize: root.iconSize
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
