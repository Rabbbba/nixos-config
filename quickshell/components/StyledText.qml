import QtQuick
import "../modules"

/**
 * @brief Themed @c Text — used everywhere instead of raw @c Text.
 *
 * Pre-applies the theme text color, the project font family, and enables
 * right-side ellipsis by default — so colors and fonts stay consistent
 * across the whole shell.
 */
Text {
    color: Theme.text
    font.family: Theme.fontFamily
    elide: Text.ElideRight
}
