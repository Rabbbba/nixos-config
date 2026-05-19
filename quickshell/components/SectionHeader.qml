import QtQuick
import "../services"

/**
 * @brief Bold heading used at the top of popout sections.
 *
 * Thin wrapper over @ref StyledText that pre-applies @c font.bold and the
 * theme text color.
 */
StyledText {
    font.bold: true
    color: Theme.text
}
