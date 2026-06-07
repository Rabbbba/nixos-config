// qmllint disable missing-property
import QtQuick
import "../services"

/**
 * @brief Themed @c Text — used everywhere instead of raw @c Text.
 *
 * Pre-applies the theme text color, the project font family, and enables
 * right-side ellipsis by default — so colors and fonts stay consistent
 * across the whole shell.
 */
Text {
    color: Theme.color.text
    font.family: Theme.font.family
    elide: Text.ElideRight
}
